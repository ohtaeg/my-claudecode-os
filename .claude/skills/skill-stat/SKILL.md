---
name: skill-stat
description: 이 프로젝트에서 호출된 스킬의 사용 통계를 CLI에 출력한다. 사용자가 `/skill-stat`을 호출할 때만 동작하며, .claude/stats/skill-usage.jsonl(로그 훅이 누적)을 읽어 총 호출 수·오늘 호출 수·스킬별 카운트·최근 호출 시각을 보여준다. 결과를 임의로 요약/가공하지 않고 셸 스크립트 출력을 그대로 사용자에게 노출한다.
---

# Skill Stat Skill

PreToolUse 훅(`log-skill-usage.sh`)이 누적해온 스킬 호출 로그를 읽어
**터미널에서 한눈에 보이는 통계**로 보여준다. 사용자가 `/skill-stat` 또는
"스킬 사용 통계 보여줘" 같이 명시적으로 요청할 때만 동작한다.

## 0. 데이터 소스

- 로그: `.claude/stats/skill-usage.jsonl` (JSONL, 한 줄당 1 이벤트)
- 필드: `timestamp`(UTC ISO8601), `skill`, `session_id`, `cwd`
- 누적 주체: `.claude/hooks/log-skill-usage.sh` (PreToolUse + Skill matcher)
- 기록 대상: 현재 `git-commit`, `tech-qna`, **그리고 추후 추가되는 프로젝트 스킬**.
  새 스킬을 추적하려면 `log-skill-usage.sh`의 `case "$SKILL" in` 분기에 이름을 추가해야 한다.

## 1. 기본 동작 (인자 없음)

사용자가 `/skill-stat`을 인자 없이 호출하면 다음 한 줄만 실행한다.

```bash
.claude/skills/skill-stat/show-stats.sh
```

**스크립트의 stdout을 그대로 사용자에게 보여준다.** 직접 마크다운 표로 다시 그리거나,
숫자를 다시 해석해 코멘트하지 않는다. 사용자가 추가 분석을 요청하지 않는 한 그대로 끝낸다.

### 예상 출력 형태

```
== Skill Usage Statistics ==
----------------------------
총 호출 :     12회
오늘 호출:    3회 (UTC 2026-05-28)
기록 시작:    2026-05-12
마지막 호출:  2026-05-28T11:17:15Z

[스킬별 호출 — 많은 순]
  tech-qna     8회    최근: 2026-05-28T11:17:15Z
  git-commit   4회    최근: 2026-05-27T18:02:44Z
```

## 2. 추가 분석 요청 처리

사용자가 기본 출력 이후 더 묻는 경우, 셸에서 `jq`로 직접 쿼리해 답한다.
**원본 로그가 사실의 출처**이며, 스크립트 출력을 메모리에 의존해 재구성하지 않는다.

| 질문 유형 | 명령 예시 |
|-----------|-----------|
| 특정 스킬만 카운트 | `jq -r 'select(.skill=="tech-qna")' .claude/stats/skill-usage.jsonl \| wc -l` |
| 최근 N건 이벤트 | `tail -n 10 .claude/stats/skill-usage.jsonl \| jq -c` |
| 특정 날짜 호출 | `jq -r 'select(.timestamp \| startswith("2026-05-27")) \| .skill' .claude/stats/skill-usage.jsonl \| sort \| uniq -c` |
| 세션별 호출 분포 | `jq -r '.session_id' .claude/stats/skill-usage.jsonl \| sort \| uniq -c \| sort -rn` |

분석 결과는 짧은 한국어 요약 한두 줄과 함께 제시한다. 표는 필요할 때만.

## 3. 로그가 비어있을 때

`show-stats.sh`가 "[skill-stat] 아직 기록된 스킬 호출이 없습니다." 메시지를 자체적으로 출력한다.
이 경우 그 메시지를 그대로 보여주고, 사용자에게 **이 프로젝트의 추적 대상 스킬**(현재 `git-commit`, `tech-qna`)을
한 번 호출해보라고 안내한다. 다른 부가 설명은 생략.

## 4. 금지 사항 (Never do)

- ❌ **숫자 가공/추측** — "약 N회 정도", "주로 X 스킬을 쓰시네요" 같은 임의 해석 금지. 출력값만 신뢰.
- ❌ **로그 수정** — `skill-usage.jsonl`은 read-only 데이터 소스로 취급. 정리·삭제 요청은 사용자가 명시할 때만.
- ❌ **다른 스킬 호출 횟수를 메모리에 저장** — 항상 파일에서 읽는다. 메모리는 빠르게 stale 된다.
- ❌ **결과 마크다운 재가공** — 사용자가 명시적으로 "표로 정리해줘"라고 하지 않는 한, 셸 출력을 그대로 둔다.

## 5. 트러블슈팅

| 증상 | 원인 | 대응 |
|------|------|------|
| "jq 가 필요합니다" | jq 미설치 | `brew install jq` 안내 |
| 통계는 나오는데 새 호출이 안 잡힘 | 새 스킬이 `log-skill-usage.sh`의 case 화이트리스트에 없음 | 해당 스크립트 편집해 스킬명 추가 |
| 모든 호출이 같은 시각으로 보임 | 시드 데이터(2026-05-28T11:17:15Z)만 있음 | 정상 — 실제 호출이 누적되면 분포가 생김 |
