# devkit marketplace

Claude Code와 Codex에서 같은 개발 원칙과 문서 형식으로 작업하기 위한 플러그인입니다. 요청의
의도를 먼저 확인하고, 여러 세션·기기·에이전트 사이에서 명세와 핸드오프를 이어갑니다.

이 저장소는 공식 플러그인 디렉터리가 아니라 **GitHub marketplace**로 배포됩니다. Claude Code와
Codex CLI가 같은 `plugins/devkit` 패키지를 설치합니다.

처음 설치한다면 **[설치부터 첫 사용까지 안내서](docs/GETTING_STARTED.md)**를 따라가면 됩니다.

## 1분 설치

자신이 쓰는 클라이언트 명령만 실행합니다.

```bash
# Claude Code
claude plugin marketplace add kynbeen/devkit-marketplace
claude plugin install devkit@devkit

# Codex CLI
codex plugin marketplace add kynbeen/devkit-marketplace
codex plugin add devkit@devkit
```

설치 후 새 세션이나 새 스레드를 열고 `/devkit:help` 또는 `$devkit-help`를 실행하세요.

## 포함된 기능

| Claude Code | Codex | 기능 |
|---|---|---|
| `/devkit:help` | `$devkit-help` | 설치 후 첫 사용과 현재 상황에 맞는 워크플로 안내 |
| `/devkit:clarify` | `$devkit-clarify` | 막연한 요청을 목표·성공 기준·범위·제약으로 구체화 |
| `/devkit:spec` | `$devkit-spec` | 확정된 의도를 `docs/specs/`에 기록 |
| `/devkit:backlog` | `$devkit-backlog` | 명세를 모듈·브랜치 단위 백로그로 분해 |
| `/devkit:handoff` | `$devkit-handoff` | 현재 상태를 `docs/handoffs/`에 기록하고 인계 |
| `/devkit:resume` | `$devkit-resume` | 최신 핸드오프의 유효성을 확인하고 작업 재개 |
| `/devkit:prefs` | `$devkit-prefs` | 개인 작업 설정을 자신의 marketplace 포크에 동기화 |

세션 시작과 사용자 프롬프트 제출 시에는 `hooks/`의 의도 우선 원칙과 개인 작업 설정이 자동으로
추가됩니다. 플러그인 훅은 사용자 권한으로 명령을 실행하므로, 설치 후 호스트가 표시하는 훅 내용을
검토하고 신뢰해야 활성화됩니다.

## Claude Code와 Codex의 관계

Codex가 Claude Code를 호출하는 구조는 아닙니다. `commands/*.md`가 공통 워크플로 원본이고,
Claude Code는 이를 명령으로 직접 읽습니다. Codex의 `skills/*/SKILL.md`는 같은 원본을 가리키며
호출 문법과 프로젝트 지침 차이만 번역하는 얇은 어댑터입니다.

```text
commands/*.md ──┬── Claude Code: /devkit:<name>
                └── Codex: skills/*/SKILL.md → $devkit-<name>
```

자세한 구조와 공개판의 예외는 [아키텍처 설명](docs/ARCHITECTURE.md)에 있습니다.

## 의도적으로 제외한 기능

- 무인 자동개발 실행기
- 텔레그램 브리지와 원격 승인
- 자동개발 결과를 합치거나 거부하는 review 워크플로

`backlog`는 남아 있지만 자동 실행기는 포함하지 않습니다. 사람이 직접 처리하거나 원하는 개발
에이전트에 모듈별로 맡기는 작업 목록으로 사용합니다.

## 설치

아래는 빠른 명령 모음입니다. 설치 확인, 첫 실행, 제거와 문제 해결까지 필요한 경우
[시작 안내서](docs/GETTING_STARTED.md)를 참고하세요.

### Claude Code

```bash
claude plugin marketplace add kynbeen/devkit-marketplace
claude plugin install devkit@devkit
```

확인:

```bash
claude plugin list
claude plugin details devkit
```

### Codex CLI

```bash
codex plugin marketplace add kynbeen/devkit-marketplace
codex plugin add devkit@devkit
```

설치 후에는 새 세션이나 새 스레드를 시작해야 스킬과 `SessionStart` 훅이 적용됩니다. Codex가
플러그인 훅을 처음 발견하면 내용을 검토하고 신뢰하는 절차가 필요합니다.

## 업데이트

```bash
# Claude Code
claude plugin marketplace update devkit
claude plugin update devkit@devkit

# Codex CLI
codex plugin marketplace upgrade devkit
codex plugin add devkit@devkit
```

업데이트 후에는 새 Claude Code 세션 또는 새 Codex 스레드를 시작해야 새 워크플로가 적용됩니다.

## 개인 설정을 기기 간 동기화하려면

기본 설치만으로도 `hooks/preferences.md`의 설정을 사용할 수 있습니다. 자신의 설정을 바꾸고 여러
기기에 동기화하려면 이 저장소를 GitHub에서 **포크**한 뒤, 처음부터 자신의 포크를 marketplace로
등록하세요.

```bash
claude plugin marketplace add <github-id>/devkit-marketplace
codex plugin marketplace add <github-id>/devkit-marketplace
```

그 후 `/devkit:prefs` 또는 `$devkit-prefs`를 실행하면 포크의
`plugins/devkit/hooks/preferences.md`를 고치고 버전·커밋·푸시·현재 기기 업데이트까지 처리합니다.
upstream인 `kynbeen/devkit-marketplace`에는 다른 사용자가 푸시할 수 없으므로, 포크 없이 개인 설정
동기화를 시작하지 않습니다.

## 호환성과 전제

- Claude Code와 Codex CLI의 플러그인 marketplace를 대상으로 합니다.
- Claude Code의 셸 형식 훅은 Windows에서 Git Bash를 사용하므로 Git for Windows가 필요합니다.
- `handoff`, `spec`, `prefs`는 요청에 따라 파일 작성, Git 커밋 또는 푸시를 수행할 수 있습니다.
  실행 전에 플러그인 소스와 워크플로를 검토하세요.

## 원본 devkit과 배포본 동기화

개인용 전체 저장소와 공개 marketplace는 완전한 양방향 미러가 아닙니다. 자동개발·텔레그램·review가
공개판으로 되살아나는 것을 막기 위해 **원본 devkit → marketplace 단방향 발행 동기화**를
사용합니다.

```powershell
# 차이만 확인
pwsh -File scripts/sync-from-devkit.ps1

# 검토 후 새 버전으로 반영
pwsh -File scripts/sync-from-devkit.ps1 -Mode Apply -Version 0.11.0
```

그대로 복사할 파일과 수동으로 유지할 공개판 어댑터를 구분합니다. 전체 정책과 릴리스 순서는
[유지관리 안내서](docs/MAINTAINING.md)에 있습니다.

## 저장소 구조

```text
devkit-marketplace/
├── .claude-plugin/marketplace.json
├── .agents/plugins/marketplace.json
├── docs/
├── scripts/
├── sync/devkit-source.json
└── plugins/devkit/
    ├── .claude-plugin/plugin.json
    ├── .codex-plugin/plugin.json
    ├── commands/
    ├── skills/
    └── hooks/
```

## 라이선스

[MIT](LICENSE)
