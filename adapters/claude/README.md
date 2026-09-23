# Claude adapter 템플릿

이 디렉토리는 하네스가 배포하는 **Claude Code 전용 실행 자산의 배포용 템플릿**이다. 프로젝트는 여기서 파일을 자기 `.claude/`로 복사해 설치한다.

`docs/`는 tool 중립 원칙만 담고 특정 tool 전용 문법을 넣지 않는다(`docs/00-docs/02-harness-boundary.md`). 그래서 Claude에서만 동작하는 subagent 정의, hook 스크립트, plan mode 문법, hook 설정은 전부 이 `adapters/claude/`에 모여 있다.

## 이 템플릿이 제공하는 것

1. **PM/CTO/PL/PA 역할 체인** — 각 역할을 실제 Claude subagent로 정의한다. 메인 세션이 혼자 네 역할을 흉내 내는 대신, `Agent(subagent_type: "pm" | "cto" | "pl" | "pa")`로 독립 컨텍스트에서 호출한다.
2. **승인 게이트 강제** — "승인 전까지 파일을 수정하지 않겠습니다"라는 선언은 아무것도 차단하지 못한다. `EnterPlanMode`를 실제로 호출해 harness가 Edit/Write를 막게 만드는 것을 규칙으로 못박는다.
3. **Prompter·Reviewer** — prompter는 작업 중 프롬프트·MD 개선을 추천하며 사용자 승인 없이 반영하지 않는다. reviewer는 PA 완료 전에 읽기 전용 검토를 수행하고 PA 재작업·재검토 후 PASS 최종본을 PL에 전달하게 한다.
4. **PA 완료 콜백 강제** — PA 서브에이전트가 끝나면 hook 한 쌍이 메인 세션의 응답 종료를 막아, 반드시 완료/실패 콜백 보고를 먼저 출력하게 한다. 사용자가 PA 종료 시점을 놓치지 않는다.

## 파일별 역할과 설치 위치

| 템플릿 | 설치 위치 | 역할 |
|---|---|---|
| `agents/*.md` | `.claude/agents/` | PM/CTO/PL/PA/Prompter/Reviewer subagent 정의 |
| `hooks/*.sh` | `.claude/hooks/` | PA 완료 콜백용 SubagentStop/Stop 훅 스크립트 |
| `hooks/*.cjs` | `.claude/hooks/` | PA 종료 시 reviewer 상태·검토·후속 조치 누락 검사 |
| `rules/01-workflow-gate.md` | `.claude/rules/process/01-workflow-gate.md` | 승인 게이트를 `EnterPlanMode`로 강제하는 Claude 전용 규칙 |
| `rules/02-agent-review.md` | `.claude/rules/process/02-agent-review.md` | 추천 승인·PA 검토 및 사용자 보고 연결 |
| `skills/ai-process-workflow/` | `.claude/skills/ai-process-workflow/` | 역할 모델·적용 강도·보고 형식·콜백 형식을 담은 skill |
| `settings.hooks.json` | `.claude/settings.json`의 `hooks` 키에 **병합** | 콜백 및 reviewer 보고 검사 훅 등록 설정 |

이 매핑은 `docs/00-docs/03-agent-dir-init.md`의 "--from-template 옵션" 기준과 동일하다. 설치는 `claude dir init --from-template`으로 요청한다.

`settings.hooks.json`은 `.claude/settings.json`을 통째로 덮어쓰지 않는다. 기존 파일의 `hooks` 키에만 병합하고 `permissions`, `env`, `model` 등 다른 키는 보존한다.

## 설치 후 필수 작업

설치만으로는 규칙이 로드되지 않는다. 프로젝트 루트 `CLAUDE.md`에서 rule과 skill을 import해야 매 세션 컨텍스트에 들어간다.

```md
@.ai-prompts/CLAUDE.md                          ← 하네스 코어 (필수)

@.claude/rules/process/01-workflow-gate.md      ← 승인 게이트 규칙 (이 줄이 없으면 규칙이 로드되지 않는다)
@.claude/rules/process/02-agent-review.md      ← 추천 승인·PA 완료 전 검토
@.claude/skills/ai-process-workflow/SKILL.md    ← 워크플로우 skill
```

subagent(`.claude/agents/*.md`)와 hook(`settings.json`)은 import가 필요 없다 — Claude Code가 디렉토리와 설정에서 자동으로 인식한다.

## 훅 동작 요약

```
PA 구현·검증 → reviewer 동기 검토 → PA 수정·재검토 → PASS 최종본
PA subagent 종료 시도
  ├─ SubagentStop 훅: check-pa-review.cjs
  │    REVIEWER_STATUS 및 검토·후속 조치 누락 시 종료 차단
  │    BLOCKED 보고는 차단 원인·다음 조치를 포함하고 완료와 구분
  └─ SubagentStop 훅: subagent-stop-flag.sh
       payload의 agent_type == "pa" 일 때만
       <프로젝트 루트>/.claude/.state/pending-pa-callback 플래그 생성

메인 세션이 응답을 끝내려는 순간
  └─ Stop 훅: check-pa-callback.sh
       플래그가 있으면 삭제 후 exit 2 (blocking)
       → stderr 내용이 Claude에게 지시로 전달되어 콜백 보고를 먼저 출력하게 됨
```

콜백용 두 셸 스크립트는 **동일한 우선순위**로 프로젝트 루트를 계산한다. 한쪽만 달라지면 플래그를 찾지 못해 콜백 강제가 조용히 무력화되므로, 수정할 때 반드시 양쪽을 같이 맞춘다.

1. 환경변수 `CLAUDE_PROJECT_DIR`
2. payload의 `cwd`
3. `git rev-parse --show-toplevel`
4. 현재 디렉토리

PA 식별은 SubagentStop payload의 공식 필드 `agent_type`으로만 한다. `settings.hooks.json`의 `"matcher": "pa"`와 스크립트 내부의 `agent_type` 검사를 둘 다 두어 방어적으로 이중 필터링한다.

## 템플릿 참조 경로

템플릿 본문의 `@CLAUDE.md`, `@.claude/...`는 하네스 내부 경로가 아니라 **설치 대상 프로젝트 루트 기준**이다. 별도 프로젝트 체크리스트나 `.ai/reviews/README.md`가 항상 존재한다고 가정하지 않는다. agent 본문 참조는 Read로 확인하며 자동 import로 간주하지 않는다.

공통 역할 기준은 하네스 진입점이 로드하는 @../../docs/20-ai-process/agents/roles/05-prompter.md 및 @../../docs/20-ai-process/agents/roles/06-reviewer.md 이다.

## 알려진 제약

- **Node.js가 필요하다.** `check-pa-review.cjs`는 Node.js로 실행한다. 이 훅은 보고 형식만 검사하며 실제 reviewer 호출과 리뷰 품질을 인증하지 않는다. PA/PL이 실제 응답·최종 변경본을 확인한다.
- **중첩 에이전트 호출이 필요하다.** 메인 → PL → PA → reviewer 호출이 제한되면 BLOCKED로 보고하고 메인 세션이 검토·재작업을 중계한다. prompter는 대화를 자동 감시하지 않으며 호출자가 관련 맥락을 전달한다.
- **bash가 필요하다.** hook 스크립트는 POSIX 셸 스크립트다. Windows에서는 Git Bash 등 `bash`를 PATH에서 찾을 수 있어야 하고, 없으면 두 훅 모두 동작하지 않는다(= 콜백 강제가 사라진다. 다른 기능은 영향 없다).
- **Claude Code 버전 의존성이 있다.** `agent_type`(SubagentStop payload 필드), `cwd`(hook payload 필드), `${CLAUDE_PROJECT_DIR}`(hook command 플레이스홀더), SubagentStop의 agent type `matcher`는 모두 Claude Code가 제공하는 것이며 버전에 따라 이름이나 동작이 달라질 수 있다. 콜백이 안 걸리거나 엉뚱한 서브에이전트에 걸리면 이 필드들부터 확인한다.
- **Codex에는 이식할 수 없는 부분이 있다.** Codex에는 SubagentStop/Stop hook 개념이 없어 "PA 완료 콜백 강제"를 그대로 옮길 수 없다. 역할 모델과 승인 절차 자체는 tool 중립이므로 `docs/`를 통해 공유되지만, 강제 수단은 Claude 전용이다.
- **콜백 플래그 훅에서 `agent_type` 추출에 실패하면 플래그를 남기지 않는다.** 이 경우 stderr에 사유를 남기되 `subagent-stop-flag.sh`는 exit 0을 유지한다(여기서 blocking하면 정상 흐름을 방해하므로). 즉 실패 방향은 "콜백이 안 걸림"이지 "세션이 멈춤"이 아니다.
- **plan mode 진입은 여전히 자발적 행동이다.** `EnterPlanMode`를 호출하기만 하면 harness가 편집을 차단하지만, 호출 자체를 강제하는 장치는 없다. 규칙 문서가 그 판단을 반복해서 못박는 이유가 이것이다.

## 설치 확인 방법

1. **subagent 인식** — `Agent(subagent_type: "pa", ...)` 호출이 "unknown agent type" 없이 실행되면 `.claude/agents/`가 인식된 것이다.
2. **콜백 강제** — 아주 작은 작업을 PA subagent로 한 번 돌린다. PA가 끝난 뒤 메인 세션이 그냥 응답을 마치지 못하고 ✅/❌ 형식의 콜백 보고를 먼저 출력하면 훅 한 쌍이 정상 동작하는 것이다.
3. **오탐 없음 확인** — Explore 등 PA가 아닌 서브에이전트를 한 번 돌린다. 이때는 콜백 보고가 강제되지 **않아야** 한다. 강제된다면 `agent_type` 필터가 동작하지 않는 것이므로 Claude Code 버전의 payload 필드를 확인한다.
4. **플래그 경로** — 콜백이 걸리는 순간 `<프로젝트 루트>/.claude/.state/pending-pa-callback`이 생성됐다가 Stop 훅에서 삭제된다. 엉뚱한 위치에 생긴다면 두 스크립트의 루트 계산 우선순위가 어긋난 것이다.
5. **규칙 로드** — 세션에서 승인 게이트 규칙을 인식하는지 확인한다. 인식하지 못하면 루트 `CLAUDE.md`의 `@.claude/rules/process/01-workflow-gate.md` import 줄이 빠졌을 가능성이 높다.

6. **Reviewer 보고 검사** — PA 종료 payload에 검토 결과가 없으면 차단되는지, PASS 또는 BLOCKED와 구체적인 검토·후속 조치가 있으면 허용되는지 확인한다. 실제 PA 작업에서는 reviewer 호출 → 수정 → 재검토 이력과 사용자 최종 보고도 확인한다.
7. **읽기 전용 역할** — prompter/reviewer의 도구가 Read, Glob, Grep으로 제한되고 Write/Edit/Bash/Agent가 허용되지 않았는지 확인한다.
