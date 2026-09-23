#!/usr/bin/env bash
# Stop 훅: 메인 세션이 응답을 끝내려는 시점에 호출된다.
# subagent-stop-flag.sh가 남긴 "콜백 보고 대기" 플래그가 있으면 exit 2(blocking)로
# 응답 종료를 막고, stderr 내용을 Claude에게 다시 지시로 전달한다.
# 이렇게 하면 사용자가 PA(서브에이전트) 작업 종료 여부를 놓치는 일이 없어진다.
#
# 경로 계산은 subagent-stop-flag.sh와 **완전히 동일한 규칙**을 써야 한다.
# 한쪽만 다르면 남긴 플래그를 찾지 못해 콜백 강제가 조용히 무력화된다.
#   ${CLAUDE_PROJECT_DIR} → payload의 cwd → git rev-parse --show-toplevel → 현재 디렉토리.
# 훅 프로세스의 cwd가 프로젝트 루트라는 보장이 공식 문서에 없어서 상대경로를 쓰지 않는다.
#
# PA 여부 판별은 이 훅이 하지 않는다. SubagentStop 훅이 공식 payload 필드 `agent_type`으로
# 이미 걸러낸 뒤에만 플래그를 남기므로, 여기서는 플래그 존재 여부만 보면 된다.
#
# JSON 파싱은 grep -o + sed로만 처리한다 (jq 같은 외부 도구 의존을 늘리지 않는다).

PAYLOAD="$(cat -)"

PAYLOAD_CWD="$(printf '%s' "$PAYLOAD" \
  | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -n 1 \
  | sed -E 's/^"cwd"[[:space:]]*:[[:space:]]*"//; s/"$//' \
  | sed 's/\\\\/\//g')"

# 프로젝트 루트 결정 — subagent-stop-flag.sh와 동일한 우선순위를 유지할 것.
if [ -n "$CLAUDE_PROJECT_DIR" ]; then
  PROJECT_DIR="$CLAUDE_PROJECT_DIR"
elif [ -n "$PAYLOAD_CWD" ]; then
  PROJECT_DIR="$PAYLOAD_CWD"
elif PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)" && [ -n "$PROJECT_DIR" ]; then
  :
else
  PROJECT_DIR="$(pwd)"
fi

FLAG="$PROJECT_DIR/.claude/.state/pending-pa-callback"

if [ -f "$FLAG" ]; then
  if ! rm -f "$FLAG" 2>/dev/null; then
    echo "check-pa-callback.sh: 플래그 파일을 지우지 못했습니다: $FLAG (다음 응답에서도 반복 차단될 수 있습니다)." >&2
  fi
  {
    echo "서브에이전트(PA) 작업이 방금 종료되었습니다. 응답을 끝내기 전에 콜백 보고를 먼저 출력하세요."
    echo ""
    echo "- 성공: ✅ 완료 / 📁 변경·생성 파일 / 📝 작업 내용 요약 / 🧪 검증 결과"
    echo "- Reviewer: 최종 PASS, 검토 기준·범위, 지적 ID별 추천 → PA 수정 → 재검증을 보고하세요. PL의 수용/보류 결정·이유도 포함하세요. 미검토/BLOCKED는 완료로 보고하지 마세요."
    echo "- 실패: ❌ 실패 / 💥 실패 이유 / 🔍 에러 분석"
    echo "  실패는 여기서 끝내지 않는다 — PL이 실패 사유를 검증한 뒤 PA에게 재작업을 지시하고 성공할 때까지 반복한다."
    echo "  기술적 원인이면 🧭 CTO와 소통, 설계/범위 문제면 🗂️ PM과 소통한다. 사용자에게 물어볼 게 있으면 ❓ 로 질문한다."
  } >&2
  exit 2
fi

exit 0
