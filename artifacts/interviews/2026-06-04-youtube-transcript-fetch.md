---
date: 2026-06-04
slug: youtube-transcript-fetch
status: dormant
source: user (인터뷰 스킬 첫 가동 검증)
---

## 라운드 트레일

### R0
- **의도**: "유튜브 url을 전달하면 자막 스크립트를 가져올 수 있는 방법"
- **진단**: 의도 일반적 — 자동화 정도·외부 의존·책임 경계 모두 열려있음. 본 OS `session-fetcher` 책임 자리, 페인포인트(흐지부지) 직격
- **옵션**:
  - A. yt-dlp + `transcript 복붙` 폴백만 (현재 가이드 유지)
  - B. yt-dlp + 외부 사이트 다운로드 폴백 표준화 (수동, S116 패턴)
  - C. `transcriptapi.com` 같은 가입형 API 자동화
  - D. 헤드리스 브라우저(Playwright) 자동화
  - E. 자막 확보를 OS 책임에서 완전 분리
- **정찰 결과** (직전 대화에서 박제):
  - `yt-dlp`: 429 차단, 옵션 우회 3종(`player_client` / `cookies-from-browser` / `--impersonate`) 다 실패
  - `youtubetotranscript.com` / `savesubs.com`: Cloudflare 403
  - `tactiq.io`: SPA, 리버스 엔지니어링 필요
  - `transcriptapi.com`: 가입 + API key + 무료 100 크레딧, 작동 명확
  - `downsub.com`: SPA, 사용자 수동 다운로드 검증됨 (S116 적용)
- **선택**: 미정 — 사용자가 의도를 더 좁힌 새 인터뷰 `fetcher-fallback-guide` 로 이어감

## 결정

(가설) 사용자가 의도를 더 좁힌 새 인터뷰로 이어가기로 함. 이 인터뷰는 R0 까지만 진행 후 dormant.

## 남은 모름 (회고 후보)

- 다음 인터뷰 `fetcher-fallback-guide` 에서 결론 도달 예상
- (메타) 인터뷰 스킬 첫 가동에서 *사용자가 의도를 새 호출로 좁히는 패턴* 발견 — 가이드에 명시할지 후속 회고 거리
