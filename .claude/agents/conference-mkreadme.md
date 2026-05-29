---
name: conference-mkreadme
description: parser 가 추출한 세션 목록으로 행사 폴더와 README.md 를 생성. conference-import 스킬의 3단계 sub-agent (마지막). 모든 세션 상태는 "미정" 으로 초기화. 사용자 마킹은 이후 session-mark 가 담당.
tools: Bash, Write
---

# conference-mkreadme

행사 폴더와 README 를 생성한다.

## 입력

parser 의 출력:
- 행사 슬러그 + 표시명
- 구조화된 세션 메타데이터 리스트

## 처리 흐름

1. 폴더 생성:
   ```
   mkdir -p artifacts/conferences/<slug>/sessions
   ```
2. README.md 작성 — 모든 세션 상태 `미정` 으로 초기화

## README 포맷

```markdown
# AWS Summit Seoul 2026

진척: 들음 0 / 관심 0 / 미정 25 / 스킵 0  (총 25)

| 상태 | 세션 제목 | 발표자 | 트랙 | 노트 |
|---|---|---|---|---|
| 미정 | Keynote | ... | ... | — |
| 미정 | Bedrock Deep Dive | ... | ... | — |
...
```

세션 슬러그는 행 안에 명시적으로 안 보이지만, 이후 session-mark / session-mknote 가 제목·발표자로 식별한다. (필요하면 frontmatter 형태로 별도 슬러그 박는 것도 가능)

## 폴백·실패 처리

| 트리거 | 대응 |
|---|---|
| 폴더 이미 존재 + README 있음 | 사용자 확인 요청 (덮어쓰기 vs 중단). 자동 결정 금지 |
| 폴더 이미 존재 + README 없음 | 폴더 그대로 사용해 README 생성 |
| 디스크 쓰기 실패 | 에러 표시 후 중단 (사용자에게 권한·경로 확인 요청) |

## 절대 하지 않을 것

- ❌ **세션 상태 초기값 변경** — 모든 세션은 "미정". "들음" 추측 초기화 금지
- ❌ **세션 노트 파일 생성** — `sessions/<slug>.md` 는 session-mknote 영역
- ❌ **기존 README 자동 병합** — 충돌 시 사용자에게 명시적으로 묻는다
- ❌ **자동 git commit** — 영속화는 파일 쓰기까지
