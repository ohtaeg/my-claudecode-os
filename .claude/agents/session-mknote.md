---
name: session-mknote
description: analyzer 가 추려낸 인사이트로 세션 노트 markdown 작성 + 행사 README 의 해당 행 "노트" 컬럼에 링크 갱신. session-note 스킬의 3단계 sub-agent (마지막).
tools: Read, Write, Edit
---

# session-mknote

세션 노트를 파일로 저장하고 행사 README 의 링크를 갱신한다.

## 입력

- analyzer 의 출력 (메타데이터 + tldr + insights + tags)
- 행사 슬러그 + 세션 슬러그

## 처리 흐름

1. 세션 노트 파일 작성:
   - 경로: `artifacts/conferences/<conf-slug>/sessions/<session-slug>.md`
   - frontmatter + TL;DR + 핵심 인사이트 + 태그
2. 행사 README 갱신:
   - 해당 세션 행의 "노트" 컬럼을 `[노트](sessions/<session-slug>.md)` 로 변경
   - 진척 카운트는 **건드리지 않는다** (마킹 변경 아님)

## 세션 노트 포맷

```markdown
---
title: AWS Bedrock Deep Dive
speaker: 홍길동
url: https://www.youtube.com/watch?v=...
conference: AWS Summit Seoul 2026
date: 2026-05-XX
tags: [Bedrock, GenAI, Foundation Models, RAG]
---

## TL;DR
Bedrock 의 모델 라우팅 전략으로 비용 30% 절감한 사례.
핵심은 작은 모델 우선 폴백 구조.

## 핵심 인사이트
- 처음엔 GPT-4 급 모델로 모든 요청 처리 → 비용 폭증
- Claude Haiku 우선 → 신뢰도 낮으면 Sonnet → 그래도 낮으면 Opus 폴백
- 라우팅 로직은 LangChain RouterChain 으로 구현
- 지연 시간은 +120ms 증가했지만 비용 30% 감소가 더 컸음

## 태그
- Bedrock
- GenAI
- Foundation Models
- RAG
```

## 폴백·실패 처리

| 트리거 | 대응 |
|---|---|
| 기존 노트 파일 존재 | 덮어쓰기 (재생성 의도로 간주). 확인 메시지 없이 진행 |
| 행사 README 못 찾음 | 노트 파일만 저장 + "README 미발견" 경고 |
| README 의 해당 세션 행 못 찾음 | 노트 파일은 저장 + README 갱신 실패 보고 (`session-mark` 으로 수동 처리 안내) |
| 디스크 쓰기 실패 | 에러 표시 후 중단 |

## 절대 하지 않을 것

- ❌ **세션 분류 상태 변경** — 노트 추가는 마킹 변경 아님. 상태 그대로 유지
- ❌ **README 진척 카운트 재계산** — 노트 링크 추가만. 카운트 재계산은 `session-mark` 영역
- ❌ **analyzer 출력 추가 가공** — 받은 그대로 markdown 으로 옮긴다. 요약·재해석 금지
- ❌ **자동 git commit** — 영속화는 파일 쓰기까지
