---
description: "Prompter 추천 승인과 PA 완료 전 Reviewer 호출·재검토·보고를 연결합니다."
---

# Prompter 추천 및 PA 완료 전 Reviewer 검토

## 관련 문서

- @.claude/agents/prompter.md
- @.claude/agents/reviewer.md
- @.claude/agents/pa.md
- @.claude/agents/pl.md

이 규칙은 @.claude/rules/process/01-workflow-gate.md 의 승인 절차와 @.claude/skills/ai-process-workflow/SKILL.md 의 PA 완료 콜백을 확장한다.

## 작업 중 Prompter 호출

- 메인 세션, PL, PA는 대화에서 반복 지시, 문서 규칙 충돌, 누락을 발견하면 `Agent(subagent_type: "prompter")`를 호출한다. PM/CTO는 호출자에게 prompter 검토 필요성을 전달한다.
- 호출자는 관련 사용자/에이전트 대화 요약, 작업 목표, 대상 MD 경로, 승인 범위를 전달한다. prompter가 대화를 자동으로 감시하거나 다른 에이전트의 컨텍스트 전체를 볼 수 있다고 가정하지 않는다.
- 추천은 대화로 보고한다. MD 생성·수정·삭제·이동·구성 변경은 구체적인 변경안을 사용자에게 보여주고 명시적으로 승인받은 범위만 메인 세션/PA가 반영한다. prompter는 승인 후에도 읽기 전용이다.
- 기존 MD 내용/구성/생성 규칙을 따르고 다른 MD 참조에는 `@`를 사용한다. CLAUDE.md의 import와 별개로 agent 본문 참조는 Read로 확인한다.

## PA → Reviewer → PA 재작업 → PL

1. PA는 구현과 검증을 마친 후, PL에 완료를 반환하기 전에 `Agent(subagent_type: "reviewer")`를 **동기 호출**한다. 승인 범위, 작업 ID, 변경 파일, 이번 작업의 diff, 검증 결과, 이전 지적사항을 제공한다.
2. reviewer는 읽기 전용으로 검토하고 PA에 PASS / REWORK / BLOCKED와 근거를 반환한다. REWORK이면 PA가 승인 범위 내에서 수정·검증 후 reviewer를 다시 호출한다.
3. 범위 밖 수정, MD 변경, 리스크 수용은 임의로 처리하지 않는다. BLOCKED와 승인 필요 사항을 PL/사용자에게 전달한다. 차단 보고는 완료본 전달이 아니다.
4. PASS 이후 코드가 바뀌면 검토를 다시 받는다. PL에는 최종 변경본에 대한 reviewer 결과와 지적사항별 수정·재검증 내역을 묶어 전달한다.
5. PL은 reviewer PASS가 있는 작업만 완료본으로 받아 통합한다. 통합 과정에서 코드가 바뀌면 PA에게 검증과 reviewer 재검토를 요청한다.
6. 메인 세션의 사용자 보고에는 reviewer 검토 기준·추천, PA 실제 수정, PL의 수용/보류 결정과 이유, 재검토 및 검증 결과를 포함한다. 추천이 없으면 `없음`으로 명시한다.

## 호출 및 종료 제약

- 메인 → PL → PA → reviewer 중첩 호출이 가능한 Claude Code가 필요하다. Agent 도구나 중첩 깊이 제한으로 호출이 실패하면 검토 완료를 주장하지 말고 BLOCKED로 보고한다. 메인 세션이 reviewer 호출과 PA 재작업을 중계한 뒤 PL에 전달한다.
- PA의 SubagentStop 훅은 완료 보고에서 `REVIEWER_STATUS: PASS` 또는 `REVIEWER_STATUS: BLOCKED`를 요구한다. REWORK는 수정·재검토를 계속한다. BLOCKED에는 구체적인 차단 원인과 다음 조치를 적는다.
- 훅은 보고 누락을 차단하는 장치이며 실제 리뷰 품질이나 호출 사실을 인증하지 않는다. PA/PL은 실제 reviewer 응답과 최종 코드의 일치 여부를 확인해야 한다.
- 리뷰 내역은 우선 대화로 전달한다. 별도 MD 기록은 설치한 하네스의 리뷰 기록 규칙과 프로젝트 기록 위치를 확인하고 사용자가 승인한 경우에만 작성한다.
