#!/usr/bin/env bash
# SubagentStop 훅: 서브에이전트가 종료될 때마다 Claude Code가 호출한다.
# 종료된 서브에이전트가 PA일 때만 "콜백 보고 대기" 플래그를 남긴다.
# 그 플래그는 Stop 훅(check-pa-callback.sh)이 읽어서 메인 세션의 응답 종료를 막는다.
#
# PA 식별 방식: stdin payload의 `agent_type` 필드를 사용한다.
#   - `agent_type`은 Claude Code 공식 문서에 정의된 SubagentStop payload 필드다.
#     값은 general-purpose / Explore / Plan 또는 커스텀 에이전트 이름(.claude/agents/<name>.md의 name).
#     이 하네스의 PA subagent는 name이 `pa`이므로 그 값만 통과시킨다.
#   - 예전에는 pa.md 본문에 심어둔 HTML 주석 마커를 서브에이전트 transcript에서 grep했다.
#     이 방식은 실제로 오탐을 냈다 — 대화에서 마커 문자열을 "인용만 해도" transcript에 남아
#     PA가 아닌 서브에이전트가 PA로 오인식됐다. 그래서 마커 grep을 버리고 공식 필드로 바꿨다.
#     transcript 경로(`agent_transcript_path`)도 공식 문서에 없는 비공식 필드라 의존하지 않는다.
#
# 경로 계산: 훅 프로세스의 cwd가 프로젝트 루트라는 보장이 공식 문서에 없으므로
#   상대경로(.claude/.state)를 쓰지 않고 아래 우선순위로 루트를 정해 절대경로를 만든다.
#   ${CLAUDE_PROJECT_DIR} → payload의 cwd → git rev-parse --show-toplevel → 현재 디렉토리.
#   check-pa-callback.sh가 완전히 동일한 규칙을 써야 플래그를 찾을 수 있다.
#
# 종료 코드: 이 훅은 항상 exit 0을 유지한다. SubagentStop에서 exit 2는 blocking이라
#   정상 흐름을 방해하므로, 실패는 stderr 메시지로만 알리고 흐름은 막지 않는다.
#
# JSON 파싱은 grep -o + sed로만 처리한다 (jq 같은 외부 도구 의존을 늘리지 않는다).

PAYLOAD="$(cat -)"

# payload에서 문자열 필드 하나를 추출한다. 값이 없으면 빈 문자열을 반환한다.
extract_field() {
  printf '%s' "$PAYLOAD" \
    | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
    | head -n 1 \
    | sed -E "s/^\"$1\"[[:space:]]*:[[:space:]]*\"//; s/\"$//"
}

AGENT_TYPE="$(extract_field agent_type)"
PAYLOAD_CWD="$(extract_field cwd | sed 's/\\\\/\//g')"

if [ -z "$AGENT_TYPE" ]; then
  echo "subagent-stop-flag.sh: payload에서 agent_type을 찾지 못해 PA 여부를 판단할 수 없습니다 (플래그를 남기지 않습니다)." >&2
  exit 0
fi

# PA가 아니면 아무 것도 하지 않는다 (PM/CTO/PL, Explore 등은 콜백 보고 대상이 아니다).
if [ "$AGENT_TYPE" != "pa" ]; then
  exit 0
fi

# 프로젝트 루트 결정 — check-pa-callback.sh와 동일한 우선순위를 유지할 것.
if [ -n "$CLAUDE_PROJECT_DIR" ]; then
  PROJECT_DIR="$CLAUDE_PROJECT_DIR"
elif [ -n "$PAYLOAD_CWD" ]; then
  PROJECT_DIR="$PAYLOAD_CWD"
elif PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)" && [ -n "$PROJECT_DIR" ]; then
  :
else
  PROJECT_DIR="$(pwd)"
fi

STATE_DIR="$PROJECT_DIR/.claude/.state"
FLAG="$STATE_DIR/pending-pa-callback"

if ! mkdir -p "$STATE_DIR" 2>/dev/null; then
  echo "subagent-stop-flag.sh: 상태 디렉토리를 만들지 못했습니다: $STATE_DIR (PA 콜백 보고가 강제되지 않습니다)." >&2
  exit 0
fi

if ! {
  date +%s
  echo "---agent_type---"
  printf '%s\n' "$AGENT_TYPE"
  echo "---stdin(payload)---"
  printf '%s' "$PAYLOAD"
} > "$FLAG" 2>/dev/null; then
  echo "subagent-stop-flag.sh: 플래그 파일을 쓰지 못했습니다: $FLAG (PA 콜백 보고가 강제되지 않습니다)." >&2
fi

exit 0
