// Validate the PA handoff report before allowing the subagent to stop.
let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { input += chunk; });
process.stdin.on('end', () => {
  try {
    const payload = JSON.parse(input);
    if (payload.agent_type !== 'pa') return;
    const report = payload.last_assistant_message || '';
    const status = report.match(/^REVIEWER_STATUS: (PASS|BLOCKED)\s*$/m);
    const hasReview = /^🔎 Reviewer 검토:\s*\S.+$/m.test(report);
    const hasFollowup = /^🔁 (추천 및 처리|다음 조치):\s*\S.+$/m.test(report);
    if (status && hasReview && hasFollowup) return;
    console.log(JSON.stringify({
      decision: 'block',
      reason: 'PL 전달 전에 reviewer를 동기 호출하세요. 지적사항은 PA가 수정·검증 후 재검토받으세요. 최종 보고에는 REVIEWER_STATUS: PASS, 🔎 Reviewer 검토:, 🔁 추천 및 처리: 항목과 실제 검토·수정 근거가 필요합니다. 호출 불가/승인 필요 등 진행할 수 없는 경우 REVIEWER_STATUS: BLOCKED, 🔎 Reviewer 검토:, 🔁 다음 조치: 에 원인과 후속 조치를 적고 실패로 보고하세요. 검토를 수행하지 않고 PASS를 작성하지 마세요.'
    }));
  } catch (error) {
    console.error(`check-pa-review: invalid hook payload: ${error.message}`);
    process.exitCode = 2;
  }
});
