---
name: conference-import
description: 컨퍼런스 세션 페이지 URL 또는 본문 텍스트로 행사를 등록할 때 호출. 사용자가 "/conference-import <url|텍스트>", "이 컨퍼런스 등록해줘", "세션 목록 정리해줘" 등을 요청하면 작동. sub-agent 3개(validator → parser → mkreadme)에 단계 위임하는 얇은 가이드.
---

# conference-import

행사 등록의 진입 스킬. **얇은 가이드**다 — 절차를 강제하지 않고 큰 원칙과 단계 책임만 박는다. 분기·예외 처리는 Claude 가 판단한다.

## 입력

다음 둘 중 하나:
- 컨퍼런스 세션 페이지 **URL 1개**
- 행사 페이지 **본문 텍스트** (사용자 폴백 입력)

## 처리 흐름 — sub-agent 3개 순차 위임

```
[1] conference-validator  → URL/텍스트가 분석 가능한가? (휴리스틱 판단)
[2] conference-parser     → HTML/텍스트 → 세션 목록 구조화
[3] conference-mkreadme   → 행사 폴더 + README 생성
```

- 각 sub-agent 는 **독립 컨텍스트**로 실행. 결과를 다음 단계로 명시적 전달
- **한 단계 실패 시 그 단계만 재시도** 가능 (다른 단계는 영향 없음)
- 단계를 건너뛰지 않는다 — 검증 없이 파싱하면 SPA 빈 응답을 그대로 저장하는 사고

## 폴백·재시도

| 트리거 | 대응 |
|---|---|
| validator 가 SPA 판정 (정적 패턴 부족) | 사용자에게 "행사 페이지 본문 텍스트를 복붙해주세요" 안내. 텍스트 받으면 **parser 단계부터** 진행 |
| parser 가 세션 0개 추출 | 사용자에게 입력 확인 요청 (URL/텍스트 다시 던지기) |
| mkreadme 가 폴더 충돌 | 기존 폴더 사용 의도인지 확인 |

## 산출물

```
artifacts/conferences/<slug>/
├─ README.md         (행사 인덱스: 진척 카운트 + 세션 테이블)
└─ activity.jsonl    (행사 작업 로그 — 활동 로그 섹션 참조)
```

- 행사 슬러그는 사용자가 지정하거나 Claude 가 파싱 결과로 추론 (예: `aws-summit-seoul-2026`)
- 모든 세션 상태는 **"미정"** 으로 초기화
- 사용자가 이후 `/session-mark` 로 들음/관심/스킵 마킹

## 활동 로그 (자동 기록)

흐름이 정상 종료되면 활동 로그에 한 줄 append:

```
파일: artifacts/conferences/<slug>/activity.jsonl
포맷:
{"ts": "<ISO 8601>", "skill": "conference-import", "action": "import",
 "details": {"slug": "<slug>", "sessions_total": N, "source": "url" | "fallback"}}
```

기록 실패는 메인 흐름을 막지 않는다 (로그는 보조 정보).

## 절대 하지 않을 것

- ❌ **행사명·URL 자동 검색** — 사이트마다 구조 다르고 카탈로그 자동화는 깨진다 (한 가지 페인포인트만 깊게)
- ❌ **여러 행사 동시 처리** — 한 번에 한 행사만
- ❌ **sub-agent 단계 건너뛰기** — 검증 → 추출 → 생성 순서 고정
- ❌ **풀텍스트 한국어 번역** — 컨퍼런스 자료를 줄거리화하지 않는다
