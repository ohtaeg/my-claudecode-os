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
    - `README.md` §4 표 + §6 MVP 조회 영역에 추가
    - `workflow.md` 3단계 다이어그램·예시에 추가
- [+] **OS 갭 발견·즉시 메꿈**: `session-mark` 인터페이스 보완 (세션 ID 도입)
  - 트리거: 세션 제목 전체를 따옴표로 묶어 호출하는 게 비현실적 — 사용자 지적
  - 결정: 세션 ID(`S1~SN`) 안정 식별자 도입, 제목 키워드 폴백 유지 (A+C 결합안)
  - 산출물:
    - `session-mark` / `session-preview` SKILL.md 입력·예시 갱신
    - `conference-mkreadme` 에이전트에 ID 부여·재발급 금지 로직 추가
    - `README.md` §4 호출 컬럼 라벨 갱신 (`<세션>` → `<세션 ID\|제목 키워드>`)
    - `workflow.md` 호출 예시 ID 기반으로 갱신
    - AWS Summit 2026 README 마이그레이션 (S1~S127 컬럼 소급 부여, 캐치테이블 = S41)
    - 후속: `/conference` + `/find-session` SKILL.md 출력 형식에 ID 컬럼 추가 (가이드↔실제 정합)
- [+] **사용자 요청 즉시 반영**: `git-commit` 스킬에 자동 push 정책 추가
  - 트리거: 사용자 명시 요청
  - 결정: 커밋 직후 `git push` 자동 실행. 안전 가드(force-push / `--no-verify` / 다른 브랜치 push 금지) 유지
  - 산출물: `.claude/skills/git-commit/SKILL.md` (§3.1 신설, §4 금지 사항 갱신, 체크리스트 보강)
- [+] **버그픽스**: `settings.json` 훅 경로를 cwd 무관하게 보강
  - 트리거: 마이그레이션 작업 중 내가 `cd` 명령을 써서 cwd 가 영구 변경됨 → PreToolUse 훅(상대 경로 `.claude/hooks/*.sh`) 이 ENOENT 로 깨짐. 사용자 신고로 발견
  - 결정: `$CLAUDE_PROJECT_DIR` 사용으로 cwd 무관 동작 (이식성 유지)
  - 산출물: `.claude/settings.json`
- [+] **문서 정합**: `README.md` §4 표 4그룹 분할 (등록/분류/노트/조회)
  - 트리거: 단일 7행 표가 분류 정체성 약하게 보임 + 본인이 스킬 카운트를 잘못 셌음 (8개라고 함, 실제 7개) — 사용자 정정
  - 결정: 등록 → 분류 → 노트 → 조회 4 미니 표로 분할. 각 그룹 헤더에 이모지·Phase 라벨
  - 산출물: `README.md` §4
- [x] `session-note` 첫 가동 (S116 슬롯)
  - 입력 URL: `https://www.youtube.com/watch?v=u8EZ5QMk8Fc`
  - 폴백 다중 발생:
    1. fetcher: yt-dlp 봇 차단 (HTTP 429, 우회 3종 실패)
    2. 사용자 외부 사이트(`downsub.com`)로 한국어 transcript 다운로드 → `artifacts/.../transcripts/S116-woowa-nova2-production.txt` 저장
    3. analyzer 단계부터 재개 (한국어 자막 입력)
  - **강제 매핑 케이스**: 영상 실제 내용 ≠ S116 마킹 제목
    - S116 마킹: "우아한형제들의 Nova 2 프로덕션 적용 여정" (장재주)
    - 영상 실제: "1000여 대의 데이터베이스서비스 우아하게 운영하기" (김정곤·오윤택, 2025-08-14 업로드)
    - 처리: frontmatter title은 S116 마킹 제목 유지, speaker·본문은 영상 실제 기준, 노트 머리에 `> [매핑 노트]` 블록으로 미스매치 박제
  - 산출물: `sessions/woowa-nova2-production.md` (TL;DR + 인사이트 9 + 태그 10), README S116 행 노트 컬럼 갱신
- [ ] `session-note` 정상 흐름 첫 가동 (캐치테이블 S41 등 매핑 일치 케이스)
  - 검증 포인트: yt-dlp 봇 차단 여부, analyzer 품질, 매핑 일치 시 frontmatter 처리
- [+] **회고 거리 채집** (Day 8 용):
  - 인자 누락 시 폴백 가이드 부재 (`/conference-status`, `/conference` 공통)
  - `/conference` 출력 길이 (미정 多수 시 UX 갭)
  - `session-preview` 의 URL/태그 필드 비어있음 → `conference-import` 가 상세 URL 미저장
  - **새 스킬·인터페이스 변경 시 갱신 매트릭스 부재** — README §4 / §6 / workflow / 각 SKILL.md 동기화가 산발적으로 누락 (find-session 추가 시 §4 표 누락, ID 도입 시 `/conference`·`/find-session` 출력 형식 누락 등 반복 발생)
  - Bash 도구 cwd persist + 상대 경로 훅 = 깨짐 패턴 (해결됨, 박제용)
  - 본인의 스킬 카운트·분류 실수 (8개라고 잘못 셈) — 사용자 정정으로 발견. OS 정체성 내재화 부족 표지
  - **`session-note` 첫 가동(S116) 채집** ↓
    - `session-analyzer` 가이드는 "영어 자막 우선" 이나 한국어 transcript 입력 케이스 처리 명시 부재 — 한국어 그대로 받아도 동작은 가능했음. 가이드 보완 필요
    - `session-fetcher` 폴백 가이드에 "transcript 복붙" 외에 **"외부 자막 다운로드 사이트(`downsub.com` 등) → 파일 저장"** 경로 추가 검토
    - 자막 저장 위치 안내가 사용자에게 명확히 전달 안 됨 (`examples/` vs `artifacts/`) — 사용자 첫 시도는 examples 하위, 이후 이동 필요
    - **강제 매핑 케이스 처리 정책 부재** — URL과 마킹 세션 컨텍스트가 다를 때(URL 매핑 오류·잘못된 영상 등) 본문/frontmatter/노트 머리 안내 표준 규칙 없음. 이번엔 임시로 "frontmatter title은 마킹 제목, speaker·본문은 영상 실제, 머리에 `[매핑 노트]` 블록" 적용
    - **노트 생성 후 상태 전이 정책 부재** — 노트가 생기면 `관심 → 들음` 으로 자동 전이할지 여부 미정. 현재는 사용자가 별도로 `/session-mark` 호출해야 함
    - **fetcher 초기 메타데이터로 매핑 검증 가능** — fetcher가 영상 제목·업로드 날짜를 미리 추출해 "마킹 세션과 다를 수 있음" 을 조기에 알린 패턴 좋았음. 표준화 가치

---

## 참고 — 다른 차원의 계획

- **자라날 단계** (기능 확장 후보): `README.md` §6 🌱
- **의도적으로 만들지 않을 것** (정체성 보호): `README.md` §6 🚫
- **사례 기록** (일회성 흐름 박제): `examples/<slug>/import-case.md`
