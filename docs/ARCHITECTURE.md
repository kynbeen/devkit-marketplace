# Claude Code와 Codex의 관계

Codex 구현은 Claude Code 프로그램을 호출하는 어댑터가 아닙니다. 두 호스트가 하나의 플러그인
패키지 안에서 같은 워크플로 문서를 각자의 방식으로 읽습니다.

```text
plugins/devkit/commands/*.md        공통 워크플로 원본
              │
       ┌──────┴──────┐
       │             │
Claude Code       Codex
명령으로 직접     skills/*/SKILL.md의 얇은 어댑터
발견·실행         └ 공통 원본을 읽고 호스트 표현만 번역

plugins/devkit/hooks/*              두 호스트가 공유하는 의도·개인 설정 지침
```

## 공통인 것

- 실제 절차와 결과물 형식은 `commands/*.md`에 있습니다.
- 명세는 `docs/specs/`, 세션 상태는 `docs/handoffs/`에 남깁니다.
- 의도 우선 원칙과 개인 설정은 `hooks/`에 있습니다.

## 호스트별로 다른 것

| 개념 | Claude Code | Codex |
|---|---|---|
| 발견 단위 | `commands/<name>.md` | `skills/devkit-<name>/SKILL.md` |
| 호출 | `/devkit:<name>` | `$devkit-<name>` |
| 프로젝트 지침 | `CLAUDE.md` | `AGENTS.md` 우선 |
| 세션 초기화 | `/clear` 또는 새 세션 | 새 스레드 또는 새 세션 |

Codex의 `SKILL.md`는 절차를 복제하지 않습니다. 대응하는 `commands/*.md`를 끝까지 읽으라고 한 뒤
`$ARGUMENTS`, `/devkit:*`, `CLAUDE.md`, `/clear` 같은 호스트 전용 표현만 Codex 의미로 바꿉니다.
그래서 공통 절차를 고칠 때는 원칙적으로 명령 문서 한 곳만 수정합니다.

## 예외

공개 marketplace는 원본 개인 저장소의 축소 배포본입니다. 다음 파일은 배포 경계 때문에 별도
어댑터로 유지합니다.

- `backlog`: 무인 자동개발 실행 연결을 제거하고 사람·에이전트용 작업 목록으로 유지
- `prefs`: upstream 대신 각 사용자의 marketplace 포크에 동기화
- `help`: 공개판 설치와 사용법을 위한 marketplace 전용 워크플로

무인 자동개발, 텔레그램, review 구현은 패키지에 들어가지 않습니다.
