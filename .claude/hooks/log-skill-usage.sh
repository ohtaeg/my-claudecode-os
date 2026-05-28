#!/usr/bin/env bash
# PreToolUse hook — Skill 도구 호출 시 이 프로젝트 자체 스킬만 골라
# .claude/stats/skill-usage.jsonl 에 한 줄짜리 JSON 이벤트로 append.
#
# 절대 메인 흐름을 막지 않는다. 어떤 실패가 나도 exit 0.

set +e

INPUT="$(cat 2>/dev/null)"
[ -z "$INPUT" ] && exit 0

# jq 없으면 조용히 종료 (로깅 포기, 사용자 호출은 계속 진행)
command -v jq >/dev/null 2>&1 || exit 0

SKILL="$(printf '%s' "$INPUT" | jq -r '.tool_input.skill // empty' 2>/dev/null)"
[ -z "$SKILL" ] && exit 0

# 이 프로젝트 자체 스킬만 기록 — 다른 스킬은 무시
case "$SKILL" in
  git-commit|tech-qna|skill-stat) ;;
  *) exit 0 ;;
esac

SESSION_ID="$(printf '%s' "$INPUT" | jq -r '.session_id // ""' 2>/dev/null)"
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // ""' 2>/dev/null)"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
STATS_DIR="$SCRIPT_DIR/../stats"
mkdir -p "$STATS_DIR" 2>/dev/null || exit 0

jq -nc \
  --arg ts "$TIMESTAMP" \
  --arg skill "$SKILL" \
  --arg sid "$SESSION_ID" \
  --arg cwd "$CWD" \
  '{timestamp: $ts, skill: $skill, session_id: $sid, cwd: $cwd}' \
  >> "$STATS_DIR/skill-usage.jsonl" 2>/dev/null

exit 0
