---
name: session-note
description: 컨퍼런스 세션의 YouTube URL 로 한국어 학습 노트를 생성할 때 호출. 사용자가 "/session-note <youtube-url>", "이 세션 정리해줘", "노트 만들어줘" 등을 요청하면 작동. sub-agent 3개(fetcher → analyzer → mknote)에 단계 위임하는 얇은 가이드.
---

# session-note

세션 학습 노트 생성의 진입 스킬. **얇은 가이드**다 — 절차를 강제하지 않고 큰 원칙과 단계 책임만 박는다. 분기·예외 처리는 Claude 가 판단한다.

## 입력

- YouTube URL 1개 (영어 자동 자막 우선)
- 폴백: 사용자가 직접 transcript 텍스트 복붙

## 처리 흐름 — sub-agent 3개 순차 위임

```
[1] session-fetcher   → yt-dlp 로 영어 자막(.vtt) 다운로드
[2] session-analyzer  → 영어 자막 → 한국어 분석·요약
[3] session-mknote    → 세션 노트 markdown 작성 + 행사 README 의 행 갱신
```

- 각 sub-agent 는 **독립 컨텍스트**로 실행
- 자막 추출 실패가 잦고 분석 재실행 욕구가 있어 단계별 재시도 가치가 크다
- 중간에 **풀텍스트 한국어 번역본은 만들지 않는다** — analyzer 가 영어 자막을 직접 읽고 한국어 인사이트만 추려낸다

## 폴백·재시도

| 트리거 | 대응 |
|---|---|
| fetcher 가 봇 차단·자막 없음 | "YouTube 의 transcript 영역을 복붙해주세요" 안내. 텍스트 받으면 **analyzer 단계부터** 진행 |
| analyzer 결과 미흡 (인사이트가 일반론으로 흐름) | 사용자가 재호출 요청하면 **analyzer 만** 다시 실행. mknote 가 결과로 노트 덮어쓰기 |
| mknote 가 기존 노트와 충돌 | 덮어쓰기 (재생성 의도로 간주) |

## 큐레이션 기준 (analyzer 단계가 따른다)

세션 노트는 다음 3개 섹션으로 구성. **그 외 정보는 의도적으로 자른다.**

| 섹션 | 내용 | 기준 |
|---|---|---|
| **TL;DR** | 1~3줄 | "이 세션을 한 문장으로 표현하면?" — 주제와 핵심 주장 |
| **핵심 인사이트** | 불릿 3~7개 | 발표자만의 관점 / 실패 경험 / 의사결정 근거. **단순 사실·일반 지식은 제외** |
| **태그** | 기술·서비스 키워드 | 검색·필터링용 |

**자막 노이즈 정규화**: AWS 기술 용어가 자동 자막에서 깨질 수 있음 (Aurora → 어울러 / Lambda → 남다 등). 문맥으로 정규화해서 표준 명칭 사용.

## 산출물

```
artifacts/conferences/<slug>/
├─ sessions/<session-slug>.md   ← frontmatter + TL;DR + 핵심 인사이트 + 태그
└─ README.md                    ← 해당 세션 행의 "노트" 컬럼에 링크 추가
```

세션 노트 파일 frontmatter:
```yaml
---
title: 세션 제목
speaker: 발표자
url: https://www.youtube.com/watch?v=...
conference: <행사 표시명>
date: YYYY-MM-DD
tags: [Lambda, DynamoDB, ...]
---
```

## 활동 로그 (자동 기록)

노트 생성이 완료되면 활동 로그에 한 줄 append:

```
파일: artifacts/conferences/<slug>/activity.jsonl
포맷:
{"ts": "<ISO 8601>", "skill": "session-note", "action": "note_created",
 "details": {"slug": "<slug>", "session": "<session-slug>",
             "url": "<YouTube URL>", "source": "yt-dlp" | "fallback"}}
```

기록 실패는 메인 흐름을 막지 않는다 (로그는 보조 정보).

## 절대 하지 않을 것

- ❌ **풀텍스트 한국어 번역** — 분량만 늘고 가치 안 늘음. analyzer 가 영어 자막을 직접 읽고 한국어 인사이트만 출력
- ❌ **추측해서 인사이트 작성** — 발표자가 명시적으로 강조한 것만. 일반 지식 채워넣기 금지
- ❌ **모호한 표현** — "전반적으로 다룬다" 같은 표현 금지. **구체적 서비스명·결정·경험**으로
- ❌ **sub-agent 단계 건너뛰기** — 자막 → 분석 → 저장 순서 고정
