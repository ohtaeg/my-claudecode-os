#!/usr/bin/env bash
# PreToolUse hook for Bash: 위험한 명령을 사전에 차단한다.
#
# 입력 (stdin):
#   {"tool_name": "Bash", "tool_input": {"command": "..."}}
#
# 동작:
#   - 아래 PATTERNS 배열의 정규식 중 하나라도 명령에 매치되면
#     permissionDecision="deny" JSON을 stdout으로 출력해 Claude Code가
#     해당 Bash 호출을 차단하도록 한다.
#   - 매치되는 게 없으면 그냥 exit 0 (Claude는 평소처럼 진행).
#
# 패턴 추가: "정규식(grep -E)|차단 이유" 형식으로 PATTERNS에 한 줄 추가.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

# command가 비어있으면 검사할 게 없으니 통과
if [ -z "$COMMAND" ]; then
  exit 0
fi

# 패턴과 이유를 두 배열로 분리 (정규식에 | 가 들어있으므로 구분자로 쓰면 잘림)
PATTERNS=(
  'rm[[:space:]]+-[a-zA-Z]*[rf][a-zA-Z]*[[:space:]]+(/|~|\$HOME|\*)'
  'git[[:space:]]+push[[:space:]]+.*(--force|[[:space:]]-f([[:space:]]|$))'
  'git[[:space:]]+reset[[:space:]]+--hard'
  ':\(\)[[:space:]]*\{[[:space:]]*:\|:&[[:space:]]*\};:'
  'dd[[:space:]]+.*of=/dev/'
  'mkfs\.'
  'chmod[[:space:]]+-R[[:space:]]+777'
)
REASONS=(
  'rm -rf 로 루트/홈/와일드카드 경로를 지우는 명령은 차단됩니다'
  'git push --force / -f 는 실수 방지를 위해 차단됩니다. 정말 필요하면 사용자가 직접 실행하세요'
  'git reset --hard 는 작업물을 영구 소실시킬 수 있어 차단됩니다. 직접 실행이 필요하면 사용자가 수행하세요'
  '포크 폭탄(fork bomb) 패턴이 감지되어 차단됩니다'
  '디스크 디바이스(/dev/*)에 직접 쓰는 dd 명령은 차단됩니다'
  '파일시스템 포맷(mkfs.*) 명령은 차단됩니다'
  'chmod -R 777 은 보안상 차단됩니다'
)

for i in "${!PATTERNS[@]}"; do
  pattern="${PATTERNS[$i]}"
  reason="${REASONS[$i]}"
  if printf '%s' "$COMMAND" | grep -Eq "$pattern"; then
    jq -nc \
      --arg reason "차단된 명령: $reason" \
      '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: $reason
        }
      }'
    exit 0
  fi
done

exit 0
