# 클로드 OS 만들기 — 개발 로드맵

> 이 문서는 **OS 개발 자체의 진척 기록**이다. OS 기능 측면의 "자라날 단계" 와는 결이 다르다.
> - **자라날 단계** (`README.md` §6 🌱): "어떤 기능이 더 생길 수 있나"
> - **이 문서**: "어떤 순서로 OS 를 만들어 갔고, 지금 어디에 있고, 다음은 무엇인가"

---

## 완료된 단계

### [x] Day 1 — OS 정체성·페인포인트 정의
- 산출물: `README.md`
- 핵심: 컨퍼런스 학습 추적 OS / 한 행사만 깊게 / 흐지부지 해소
- 행동 원칙 3가지: 점진적 확장 / 인터랙션 중심 / 인사이트 단위 압축

### [x] Day 2 — End-to-end 워크플로우 시나리오
- 산출물: `workflow.md`
- 핵심: 0~5단계 사용 흐름 + ASCII / Mermaid 다이어그램 + 폴백 시나리오 표

### [x] Day 3 — 스킬 6개 SKILL.md 작성
- 산출물: `.claude/skills/<name>/SKILL.md` × 6
- 위임 스킬: `conference-import`, `session-note`
- 단일 스킬: `session-mark`, `session-preview`, `conference-status`, `conference`

### [x] Day 4 — 에이전트 6개 작성
- 산출물: `.claude/agents/<name>.md` × 6
- Phase 1: `conference-validator` / `conference-parser` / `conference-mkreadme`
- Phase 2: `session-fetcher` / `session-analyzer` / `session-mknote`

### [x] Day 5 — 첫 가동 테스트 (AWS Summit Seoul 2026)
- 입력: `https://summit-seoul.nangman.cloud/`
- `conference-validator` → **FALLBACK** (SPA 추정, 패턴 0개)
- 폴백 처리: 사용자가 Network 탭에서 비공식 API 발견 → 사례 기록
- 산출물:
  - `examples/aws-summit-seoul-2026/sessions.json` (원본 응답, 127 세션)
  - `examples/aws-summit-seoul-2026/import-case.md` (비공식 API 사용 사례)
  - `artifacts/conferences/aws-summit-seoul-2026/README.md` (Day 1: 76 / Day 2: 51, 모두 "미정")
- 회고:
  - validator FALLBACK 안내가 의도대로 작동
  - 비공식 API 를 OS 정식 흐름이 아닌 **사례 기록** 으로 자리매김 → 정체성 보존
  - parser·mkreadme 가 한 번에 127 세션을 처리해 README 생성

### [x] Day 6 — 활동 로그 도입
- 도입: 행사별 `artifacts/conferences/<slug>/activity.jsonl`
- 영향 스킬: `conference-import` / `session-mark` / `session-note` (SKILL.md 가이드 갱신)
- 백필: AWS Summit Seoul 2026 import 작업도 첫 줄로 기록

---

## 다음 단계 (계획)

### [ ] Day 8 — 첫 회고
- 잘 된 것
- 어색한 것 (스킬 호출 자연스러움 / 폴백 흐름 / 노트 품질)
- README / workflow / SKILL.md 다듬을 부분 식별

---

## 진행 중

### Day 7 — Phase 2 실전 가동 (진행 중, 2026-06-04 ~)
- [x] `session-mark`: 캐치테이블 세션 1개 "관심" 마킹 (`catchtable-claudecode-on-bedrock-proxy`)
- [x] 조회 스킬 3종 첫 가동: `/conference-status`, `/conference`, `/session-preview`
- [+] **OS 갭 발견·즉시 메꿈**: `find-session` 스킬 추가
  - 트리거: 127 세션 중 키워드로 좁히는 흐름 필요 — Day 7 진행 중 직접 발견
  - 결정: 제목 검색만, 공백 구분 OR 매칭, 유사어 제안 없음
  - 산출물:
    - `.claude/skills/find-session/SKILL.md` (신규)
    - `README.md` §6 MVP 조회 영역에 추가
    - `workflow.md` 3단계 다이어그램·예시에 추가
- [ ] `session-note`: 캐치테이블 세션 YouTube URL 공개 대기 중
  - 검증 포인트: yt-dlp 봇 차단 여부, analyzer 품질
- [+] **회고 거리 채집** (Day 8 용):
  - 인자 누락 시 폴백 가이드 부재 (`/conference-status`, `/conference` 공통)
  - `/conference` 출력 길이 (미정 多수 시 UX 갭)
  - `session-preview` 의 URL/태그 필드 비어있음 → `conference-import` 가 상세 URL 미저장

---

## 참고 — 다른 차원의 계획

- **자라날 단계** (기능 확장 후보): `README.md` §6 🌱
- **의도적으로 만들지 않을 것** (정체성 보호): `README.md` §6 🚫
- **사례 기록** (일회성 흐름 박제): `examples/<slug>/import-case.md`
