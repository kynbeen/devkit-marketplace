# Claude Code와 Codex의 관계

Codex 구현은 Claude Code 프로그램을 호출하는 어댑터가 아닙니다. 두 호스트가 하나의 플러그인
패키지 안에서 같은 워크플로 문서를 각자의 방식으로 읽습니다.

```text
plugins/devkit/commands/*.md        공통 워크플로 원본
              │
       ┌──────┴──────┐
       │             │
Claude Code       Codex
명령으로 직접     codex-skills/*/SKILL.md의 얇은 어댑터
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
| 발견 단위 | `commands/<name>.md` | `codex-skills/devkit-<name>/SKILL.md` |
| 호출 | `/devkit:<name>` | `$devkit-<name>` |
| 프로젝트 지침 | `CLAUDE.md` | `AGENTS.md` 우선 |
| 세션 초기화 | `/clear` 또는 새 세션 | 새 스레드 또는 새 세션 |

Codex의 `SKILL.md`는 절차를 복제하지 않습니다. 대응하는 `commands/*.md`를 끝까지 읽으라고 한 뒤
`$ARGUMENTS`, `/devkit:*`, `CLAUDE.md`, `/clear` 같은 호스트 전용 표현만 Codex 의미로 바꿉니다.
그래서 공통 절차를 고칠 때는 원칙적으로 명령 문서 한 곳만 수정합니다.

## 어댑터가 `codex-skills/`에 있는 이유

두 호스트 모두 플러그인 루트의 `skills/`를 **기본 검색 위치로 자동 추가**합니다. manifest의
`skills` 필드도 기본값을 대체하지 않고 거기에 더할 뿐이라, `skills/`에 둔 파일을 한쪽에서만
빼는 방법이 없습니다.

어댑터를 `skills/`에 두면 Claude Code가 `commands/`의 일곱 개에 더해 어댑터 일곱 개까지 읽어
`/devkit:clarify`와 `/devkit:devkit-clarify`가 나란히 보이고, 매 세션 컨텍스트도 그만큼 더
씁니다. 0.10.0에서 실제로 그랬습니다 — `claude plugin details devkit`이 `Skills (14)`를
보고했습니다.

Codex의 `skills` 필드는 임의의 상대 경로를 받습니다. 그래서 어댑터를 `codex-skills/`로 옮기고
`.codex-plugin/plugin.json`이 그 경로를 가리키게 했습니다. Codex는 그대로 일곱 개를 발견하고,
Claude Code는 자동 검색 대상이 아니므로 `commands/`의 일곱 개만 읽습니다.

`scripts/validate.ps1`이 `plugins/devkit/skills`가 다시 생기지 않는지 매번 확인합니다.

## `commands/`를 유지하는 이유

Claude Code의 최신 문서는 새 플러그인에 `commands/` 대신 `skills/`를 권합니다(두 방식 모두
계속 동작합니다). 이 저장소는 `commands/`를 유지합니다. 여기서 `skills/`는 Codex 어댑터가
쓰던 이름이고, 공통 원본과 호스트 어댑터를 같은 디렉터리 이름으로 겹치게 두면 위에서 설명한
중복 로딩이 바로 되돌아오기 때문입니다.

## 예외

공개 marketplace는 원본 개인 저장소의 축소 배포본입니다. 다음 파일은 배포 경계 때문에 별도
어댑터로 유지합니다.

- `backlog`: 무인 자동개발 실행 연결을 제거하고 사람·에이전트용 작업 목록으로 유지
- `prefs`: upstream 대신 각 사용자의 marketplace 포크에 동기화
- `help`: 공개판 설치와 사용법을 위한 marketplace 전용 워크플로

무인 자동개발, 텔레그램, review 구현은 패키지에 들어가지 않습니다.
