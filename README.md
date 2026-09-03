# devkit marketplace

Claude Code, Codex, Antigravity에서 같은 개발 원칙과 문서 형식으로 작업하기 위한 플러그인입니다.
요청의 의도를 먼저 확인하고, 여러 세션·기기·에이전트 사이에서 명세와 핸드오프를 이어갑니다.

이 저장소는 공식 플러그인 디렉터리가 아니라 **GitHub marketplace**로 배포됩니다. Claude Code와
Codex CLI가 같은 `plugins/devkit` 패키지를 설치하고, Antigravity는 `plugins/antigravity` 원격 URL로
직접 설치합니다.

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

# Antigravity (원격 URL 직접 설치)
agy plugin install https://github.com/kynbeen/devkit-marketplace/plugins/antigravity
agy plugin enable devkit
```

설치 직후 바로 `/devkit:help` 또는 `$devkit-help`, Antigravity에서는 `devkit-help` 스킬을 실행하면 됩니다. Claude Code가
`Run /reload-plugins to activate.`라고 안내하면 그때만 `/reload-plugins`를 실행하세요. Codex는
새 스레드를 열어야 스킬과 훅이 적용됩니다. Antigravity도 새 세션부터 적용됩니다.

## 포함된 기능
 
Antigravity는 `plugins/antigravity` 패키지를 통해 7개 스킬(`devkit-*`)과 규칙을 읽으므로 워크플로 구성은 세 호스트가
같습니다.
 
| Claude Code | Codex | Antigravity | 기능 |
|---|---|---|---|
| `/devkit:help` | `$devkit-help` | `devkit-help` | 설치 후 첫 사용과 현재 상황에 맞는 워크플로 안내 |
| `/devkit:clarify` | `$devkit-clarify` | `devkit-clarify` | 막연한 요청을 목표·성공 기준·범위·제약으로 구체화 |
| `/devkit:spec` | `$devkit-spec` | `devkit-spec` | 확정된 의도를 `docs/specs/`에 기록 |
| `/devkit:backlog` | `$devkit-backlog` | `devkit-backlog` | 명세를 모듈·브랜치 단위 백로그로 분해 |
| `/devkit:handoff` | `$devkit-handoff` | `devkit-handoff` | 현재 상태를 `docs/handoffs/`에 기록하고 인계 |
| `/devkit:resume` | `$devkit-resume` | `devkit-resume` | 최신 핸드오프의 유효성을 확인하고 작업 재개 |
| `/devkit:prefs` | `$devkit-prefs` | `devkit-prefs` | 개인 작업 설정을 자신의 marketplace 포크에 동기화 |

세션 시작과 사용자 프롬프트 제출 시에는 `hooks/` 또는 Antigravity 규칙(`rules/AGENTS.md`)의 의도 우선 원칙과 개인 작업 설정이 자동으로
추가됩니다.

## 세 호스트의 관계

한쪽이 다른 쪽을 호출하는 구조가 아닙니다. `commands/*.md`가 공통 워크플로 원본이고, 각 호스트가
자기 방식으로 같은 파일을 읽습니다. Claude Code는 명령으로 직접 읽고, Codex의
`codex-skills/*/SKILL.md`는 같은 원본을 가리키며 호출 문법과 프로젝트 지침 차이만 번역하는 얇은
어댑터이며, Antigravity는 전용 패키지 `plugins/antigravity`를 통해 스킬과 규칙을 읽습니다.

```text
commands/*.md ──┬── Claude Code: /devkit:<name> (plugins/devkit)
                ├── Codex: codex-skills/*/SKILL.md → $devkit-<name> (plugins/devkit)
                └── Antigravity: skills/devkit-*/SKILL.md → devkit-<name> (plugins/antigravity)
```

어댑터를 `skills/`가 아니라 `codex-skills/`에 두는 이유는, Claude Code가 플러그인 루트의
`skills/`를 **자동으로 추가 검색**하기 때문입니다. 거기에 두면 Claude Code가 `commands/`의 일곱
개에 더해 Codex 어댑터까지 읽어 워크플로가 열네 개로 보입니다. Codex는
`.codex-plugin/plugin.json`의 `skills` 경로를 따르므로 위치를 옮겨도 그대로 일곱 개를
발견합니다. Antigravity는 플러그인 루트의 `skills/<name>/SKILL.md`와 `rules/AGENTS.md`를 표준 규격으로
요구하므로, 전용 패키지 `plugins/antigravity`를 별도로 제공하여 세 호스트 모두 충돌과 중복 없이 7개 워크플로를 사용할 수 있습니다.

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

Codex는 설치 후 새 스레드를 시작해야 스킬과 `SessionStart` 훅이 적용됩니다. Codex가 플러그인
훅을 처음 발견하면 내용을 검토하고 신뢰하는 절차가 필요합니다.

### Antigravity

Antigravity는 깃허브 URL을 인자로 주면 리포를 직접 클론하지 않아도 원격에서 바로 설치할 수 있습니다:

```bash
agy plugin install https://github.com/kynbeen/devkit-marketplace/plugins/antigravity
agy plugin enable devkit
```

확인:

```bash
agy plugin list
```

`devkit`의 components에 `skills`가 나오면 정상 설치된 것입니다. 새 스킬과 규칙은 **새
Antigravity 세션부터** 적용됩니다.

## 업데이트

```bash
# Claude Code
claude plugin marketplace update devkit
claude plugin update devkit@devkit

# Codex CLI
codex plugin marketplace upgrade devkit
codex plugin add devkit@devkit

# Antigravity (동일한 명령으로 업데이트)
agy plugin install https://github.com/kynbeen/devkit-marketplace/plugins/antigravity
agy plugin enable devkit
```

`claude plugin update`는 적용에 재시작이 필요하다고 스스로 안내합니다. 업데이트 후에는 새
Claude Code 세션, 새 Codex 스레드, 새 Antigravity 세션을 시작하세요. (처음 **설치**할 때는
Claude Code에 재시작이 필요하지 않습니다. 위의 1분 설치를 참고하세요.)

## 개인 설정을 기기 간 동기화하려면

기본 설치만으로도 `hooks/preferences.md`의 설정을 사용할 수 있습니다. 자신의 설정을 바꾸고 여러
기기에 동기화하려면 이 저장소를 GitHub에서 **포크**한 뒤, 처음부터 자신의 포크를 marketplace로
등록하세요.

```bash
claude plugin marketplace add <github-id>/devkit-marketplace
codex plugin marketplace add <github-id>/devkit-marketplace
# Antigravity는 포크를 클론한 뒤 그 경로에서 설치합니다.
```

그 후 `/devkit:prefs` 또는 `$devkit-prefs`를 실행하면 포크의
`plugins/devkit/hooks/preferences.md`를 고치고 버전·커밋·푸시·현재 기기 업데이트까지 처리합니다.
upstream인 `kynbeen/devkit-marketplace`에는 다른 사용자가 푸시할 수 없으므로, 포크 없이 개인 설정
동기화를 시작하지 않습니다.

## 호환성과 전제

- Claude Code와 Codex CLI의 플러그인 marketplace, 그리고 Antigravity(`agy`)의 로컬 경로 설치를
  대상으로 합니다. Antigravity는 GitHub marketplace 등록을 지원하지 않습니다.
- Claude Code의 셸 형식 훅은 Windows에서 Git Bash가 있으면 Git Bash로, 없으면 PowerShell로
  실행됩니다. devkit 훅은 `cat` 한 줄만 쓰고 플러그인 경로는 Claude Code가 미리 치환하므로 두
  환경 모두에서 동작합니다.
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
pwsh -File scripts/sync-from-devkit.ps1 -Mode Apply -Version 1.2.0
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
    ├── plugin.json     Antigravity 플러그인 메타
    ├── hooks.json      Antigravity 훅 등록
    ├── commands/       공통 워크플로 원본 (Claude Code와 Antigravity가 직접 읽음)
    ├── codex-skills/   Codex 전용 얇은 어댑터
    └── hooks/
```

## 라이선스

[MIT](LICENSE)
