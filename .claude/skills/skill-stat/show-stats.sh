#!/usr/bin/env bash
# Skill 호출 통계를 사람이 읽기 좋은 형태로 출력한다.
#
# 입력: .claude/stats/skill-usage.jsonl
#   PreToolUse 훅(log-skill-usage.sh)이 한 줄당 하나의 JSON 이벤트를 append.
#   필드: timestamp(UTC ISO8601), skill, session_id, cwd
#
# 출력: 총 호출 / 오늘 호출 / 기록 기간 / 스킬별 카운트 + 최근 호출 시각
#
# 의존성: jq, date (BSD/GNU 모두 호환 — date -u +%Y-%m-%d 만 사용)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG="$SCRIPT_DIR/../../stats/skill-usage.jsonl"

if ! command -v jq >/dev/null 2>&1; then
  echo "[skill-stat] jq 가 필요합니다. brew install jq 후 다시 시도하세요." >&2
  exit 1
fi

if [ ! -s "$LOG" ]; then
  echo "[skill-stat] 아직 기록된 스킬 호출이 없습니다."
  echo "             로그 파일: $LOG"
  echo "             (PreToolUse:Skill 훅이 호출되면 자동으로 누적됩니다)"
  exit 0
fi

TODAY_UTC="$(date -u +%Y-%m-%d)"

jq -sr --arg today "$TODAY_UTC" '
  . as $events
  | ($events | length) as $total
  | ($events | min_by(.timestamp).timestamp[0:10]) as $first
  | ($events | max_by(.timestamp).timestamp) as $last
  | ([$events[] | select(.timestamp | startswith($today))] | length) as $today_count
  | ($events
      | group_by(.skill)
      | map({
          skill: .[0].skill,
          count: length,
          last: (max_by(.timestamp).timestamp)
        })
      | sort_by(-.count)
    ) as $by_skill
  | (($by_skill | map(.skill | length) | max) // 0) as $name_w
  | "== Skill Usage Statistics ==",
    "----------------------------",
    "총 호출 :     \($total)회",
    "오늘 호출:    \($today_count)회 (UTC \($today))",
    "기록 시작:    \($first)",
    "마지막 호출:  \($last)",
    "",
    "[스킬별 호출 — 많은 순]",
    ( $by_skill[]
      | "  " + .skill + (" " * ($name_w - (.skill | length))) + "   "
              + (.count | tostring) + "회"
              + "    최근: " + .last
    )
' "$LOG"
