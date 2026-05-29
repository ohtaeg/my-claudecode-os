# AWS Summit Seoul 2026 — import 사례 기록

> ⚠️ **이 문서는 OS 정식 흐름 명세가 아닙니다.**
> 한 번 진행한 폴백 흐름을 학습 기록으로 박제한 사례.
> OS 의 정식 흐름은 `conference-import` SKILL.md 와 sub-agent 가이드를 따른다.

---

## 행사

- 이름: **AWS Summit Seoul 2026**
- 페이지 URL: `https://summit-seoul.nangman.cloud/`
- 슬러그: `aws-summit-seoul-2026`
- 진행 일자: 2026-05-29

---

## 1단계 — `conference-validator` 결과: **FALLBACK**

`WebFetch` 로 페이지 본문 가져오기 시도. 휴리스틱 패턴 검출 결과:

| 패턴 | 발견 |
|---|---|
| 시간 형식 (10:00 등) | **0개** |
| 세션 제목 헤딩 (h2/h3/h4) | **0개** |
| 발표자 이름 패턴 | **0개** |

**판정**: SPA 추정. 정적 HTML 에 세션 데이터 없음. 페이지가 React/Next.js 같은 CSR 로 데이터를 동적 로드함.

→ validator 가이드대로 **fallback 안내**: "행사 페이지 본문을 복붙해주세요"

---

## 2단계 — 폴백 텍스트 마련: 비공식 API 호출

⚠️ **사이트 자체가 AWS 공식 사이트가 아닌 커뮤니티/비공식 사이트로 보입니다.**
운영자의 결정으로 API 가 언제든 사라지거나 변경될 수 있어 **OS 정식 흐름에 박지 않았습니다.**

### 발견 경위

브라우저 개발자 도구 → Network 탭에서 페이지 로드 시 호출되는 XHR 확인. 한 엔드포인트가 세션 데이터를 통째로 반환:

```
GET https://summit-seoul.nangman.cloud/api/v1/sessions
```

### 응답 구조

**최상위 envelope**:
```json
{
  "success": true,
  "data": [ /* 127 세션 */ ],
  "meta": { /* 메타데이터 */ },
  "error": null
}
```

**`data[]` 의 각 세션 필드**:

| 필드 | 타입 | 의미 | 예시 |
|---|---|---|---|
| `id` | string | 세션 고유 ID (full) | `events-cards-interactive-summits-seoul-2026#wps201` |
| `sessionCode` | string | 짧은 세션 코드 | `WPS201` |
| `title` | string | 한글 제목 | "규제 환경에서의 통제 가능한 AI 에이전트 아키텍처" |
| `description` | string | 상세 설명 (100~300자) | ... |
| `speakers` | array | 발표자 목록 | `[{name, title, organization}]` |
| `timeSlot` | object | 시간 | `{start: "16:10", end: "16:50"}` |
| `day` | number | 개최일 | `1` or `2` |
| `location` | string | 장소 (가능하면) | `"그랜드볼룸(1F) 101+102"` 또는 빈 문자열 |
| `level` | string | 난이도 | `"100"`/`"200"`/`"300"`/`"400"` |
| `track` | string | 트랙 | `"Public Sector"`, `"Startup"`, ... |
| `category` | array | 카테고리 | `["Artificial Intelligence (AI)"]` |
| `sessionType` | string | 형식 (영문) | `"Breakout Session"`, `"Keynote"`, ... |
| `sessionTypeKr` | string | 형식 (한글) | `"브레이크아웃 세션"` |
| `targetRole` | array | 대상 역할 | `["developer-engineer"]` |
| `industry` | array | 대상 산업 | `["government", "professional-services"]` |

**`meta` 의 메타데이터**: 총 세션 수, 마지막 업데이트, 트랙 목록, 시간 슬롯, 카테고리, 레벨, 세션 타입 종류 — 전부 enumerable.

---

## 3단계 — API JSON → `conference-parser` 입력 매핑

```
API JSON 필드             →  parser 입력 (sessions 배열 항목)
──────────────────────────────────────────────────────────
sessionCode               →  slug (소문자, kebab-case 변환)
title                     →  title
speakers[0].name          →  speaker
speakers[0].organization  →  speaker_org (선택)
timeSlot.start            →  time
day                       →  day (1 / 2)
track                     →  track
level                     →  level (100/200/300/400)
location                  →  location (옵션)
category                  →  tags (배열)
sessionTypeKr             →  session_type (참고용)
```

매핑 후 parser 가 출력해야 할 yaml 예시:
```yaml
conference_slug: aws-summit-seoul-2026
conference_title: AWS Summit Seoul 2026
sessions:
  - slug: wps201
    title: "규제 환경에서의 통제 가능한 AI 에이전트 아키텍처"
    speaker: "최인영"
    speaker_org: "AWS"
    time: "16:10"
    day: 1
    track: "Public Sector"
    level: "200"
    tags: ["Artificial Intelligence (AI)"]
```

---

## 4단계 — 저장된 원본 데이터

- 파일: [`sessions.json`](sessions.json) (이 디렉토리)
- 크기: 약 145KB
- 저장 일자: 2026-05-29
- 명령:
  ```bash
  curl -s -o examples/aws-summit-seoul-2026/sessions.json \
       https://summit-seoul.nangman.cloud/api/v1/sessions
  ```

원본을 보존했으므로 API 가 추후 깨져도 이 데이터로 재현 가능.

---

## 다음 단계 (사례 재활용 시)

1. `sessions.json` 을 새로 fetch 하거나 보존된 파일 사용
2. `conference-parser` 단계 — JSON → 세션 메타데이터 yaml
3. `conference-mkreadme` 단계 — 행사 폴더 + README 생성

---

## 경고 사항

- ⚠️ **비공식 API**. 운영자 결정으로 중단·변경 가능. 다음에 깨질 수 있음
- ⚠️ **AWS 공식 행사명 사용**. 운영자의 정식 권한·운영 의도 모호
- ⚠️ **OS 가 자동으로 호출하지 않는다.** 사용자가 일회성으로 사용한 흐름의 기록일 뿐
- ⚠️ **트래픽 부담 회피**. OS 정식 폴백으로 박지 않은 이유 중 하나 — 다음 사용자가 자동 호출하면 운영자 서버 부담
