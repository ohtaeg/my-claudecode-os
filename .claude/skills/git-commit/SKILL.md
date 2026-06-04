---
name: git-commit
description: 이 프로젝트에서 git 커밋을 만들 때 사용하는 가이드. 사용자가 "커밋해줘", "commit", "깃에 올려줘" 등을 요청할 때 호출. 메시지 형식, 사전 확인 절차, 커밋 직후 자동 push, 금지 사항(force-push 등)을 정의한다.
---

# Git Commit Skill

이 프로젝트에서 git 커밋을 만들 때 반드시 따라야 하는 절차와 규칙.

## 0. 사전 확인 (Pre-flight)

커밋을 만들기 전 항상 아래 3가지를 **병렬로** 실행해 현재 상태를 파악한다.

```bash
git status        # untracked / modified 파일 확인
git diff          # 실제 변경 내용 확인 (staged + unstaged 모두)
git log --oneline -5   # 기존 커밋 스타일 확인
```

확인할 것:
- `.env`, 자격증명, 큰 바이너리 등 **민감/불필요 파일**이 섞여 있지 않은가
- 사용자가 의도하지 않은 파일(`.idea/`, `.DS_Store` 등 IDE/OS 부산물)이 포함되려 하는가
  → 포함될 것 같으면 **커밋 전에 사용자에게 알리고 확인** 받는다

## 1. 메시지 형식

```
<type> : <subject>

<body (선택)>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

### type 종류

| type     | 사용 시점                                     |
| -------- | --------------------------------------------- |
| feat     | 새 기능 추가                                  |
| fix      | 버그 수정                                     |
| docs     | 문서(`*.md`)만 수정                           |
| chore    | 빌드/설정/도구 변경, 의미 없는 잡일           |
| refactor | 동작 변화 없는 코드 구조 개선                 |
| test     | 테스트 추가/수정                              |
| style    | 포매팅, 세미콜론 등 코드 의미와 무관한 변경   |

### 규칙

- `type` 뒤에 **공백 + 콜론 + 공백** (`docs : claude.md` 스타일 유지 — 기존 히스토리와 일관성)
- subject는 **한국어** 또는 영어, 50자 이내, 마침표 없음
- body는 선택. **무엇(what)이 아니라 왜(why)** 를 적는다. 코드를 보면 무엇은 알 수 있다.
- 작성자 정보로 **Co-Authored-By 라인을 항상 포함**한다 (Claude가 만든 커밋임을 명시)

### 좋은 예 / 나쁜 예

| 좋은 예                                    | 나쁜 예                              |
| ------------------------------------------ | ------------------------------------ |
| `feat : git-commit 스킬 추가`              | `add stuff` (type 없음, 내용 모호)   |
| `fix : 토큰 만료 시 401 대신 403 반환`     | `버그 수정함` (구체성 없음)          |
| `docs : CLAUDE.md에 커밋 규칙 링크 추가`   | `docs:claude.md` (공백 불일치)       |

## 2. 스테이징 규칙

- 파일은 **이름으로 명시**해서 추가한다: `git add temp.md README.md`
- `git add -A`, `git add .` 는 **사용하지 않는다** — `.env`나 IDE 파일이 딸려 들어갈 위험이 있다
- 한 커밋에는 **하나의 논리적 변경**만 담는다. 여러 종류 변경이 섞여 있으면 분리해 별도 커밋으로

## 3. 실행 — 커밋 → 자동 Push

여러 줄 메시지는 반드시 **heredoc**으로 전달해 포매팅을 보존한다.

```bash
git add <files> && git commit -m "$(cat <<'EOF'
<type> : <subject>

<body>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

커밋 직후 `git status`로 결과를 확인하고, **이어서 자동으로 `git push` 를 실행**한다. push 정책은 3.1 절 참조.

## 3.1 자동 Push 정책

이 프로젝트의 `/git-commit` 은 **커밋 → push 까지 한 흐름**이다. 사용자 별도 요청 없이도 커밋 성공 직후 push 가 진행된다.

**기본 동작**
- 커밋 성공 시 즉시 `git push` 실행
- 처음 push 하는 브랜치는 `git push -u origin <현재 브랜치>` 로 upstream 동시 설정

**안전 가드 (강제 유지)**
- ❌ `--force` / `--force-with-lease`: 절대 금지 (사용자가 명시 요청 시에만 가능)
- ❌ `--no-verify`, pre-push 훅 우회: 금지
- ❌ 다른 브랜치·다른 remote 로 push: 명시 요청 없으면 금지 (현재 브랜치 → upstream 만)

**Push 실패 시**
- non-fast-forward 등 거부 → 사용자에게 알리고 멈춤. `git pull --rebase` 같은 후속 작업은 **자동으로 하지 않음**
- 권한·네트워크 문제 → 에러 메시지 그대로 보고
- push 가 실패해도 **로컬 커밋은 그대로 유지** (롤백 안 함)

## 4. 금지 사항 (Never do)

- ❌ **`--no-verify`** — pre-commit / pre-push 훅을 건너뛰지 않는다. 훅이 실패하면 원인을 고친다
- ❌ **`--amend`** — 사용자가 명시적으로 요청하지 않는 한 항상 **새 커밋**을 만든다
- ❌ **force-push** (`--force`, `--force-with-lease`) — 강제 푸시 금지. 사용자가 명시 요청한 경우에만 (3.1 참조)
- ❌ **빈 커밋** — 변경 사항이 없으면 커밋하지 않는다
- ❌ **민감 파일 커밋** — `.env`, 키, 토큰 등이 보이면 즉시 멈추고 사용자에게 알린다
- ❌ **사용자 미요청 시 자동 커밋** — 사용자가 "커밋해줘"라고 말했을 때만 커밋한다 (`/git-commit` 슬래시 호출 포함)

## 5. 훅(pre-commit) 실패 시

훅이 실패하면 **커밋이 만들어지지 않은** 상태다. 이때:

1. 실패 원인(린트, 타입체크, 테스트 등)을 **고친다**
2. 고친 내용을 다시 `git add`
3. **새 커밋**을 만든다 (`--amend` 금지 — 이전 커밋이 없으므로 이전의 다른 커밋을 덮을 위험)

## 6. 체크리스트

커밋 직전 마음속으로 확인:

- [ ] `git status`로 들어갈 파일을 확인했는가
- [ ] 민감/불필요 파일이 섞이지 않았는가
- [ ] type이 변경 성격에 맞는가
- [ ] subject가 50자 이내, 마침표 없는가
- [ ] Co-Authored-By 라인이 들어가는가
- [ ] 사용자가 명시적으로 커밋을 요청했는가

Push 직전 마음속으로 확인:

- [ ] force-push 가 아닌가 (일반 push 만)
- [ ] 현재 브랜치 → upstream 으로 가는 단순 push 인가
