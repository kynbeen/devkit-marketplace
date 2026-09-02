# devkit 시작 안내서

devkit은 Claude Code, Codex, Antigravity에서 개발 요청을 구체화하고, 명세와 세션 인계를 같은
형식으로 남기게 해 주는 플러그인입니다. 설치에 API 키나 별도 서버는 필요하지 않습니다.

## 1. 준비물

- Git
- Claude Code, Codex CLI, Antigravity(`agy`) 중 사용할 클라이언트의 최신 버전
- Windows에서 Claude Code 훅은 Git Bash가 있으면 Git Bash로, 없으면 PowerShell로 실행됩니다.
  devkit 훅은 두 환경 모두에서 동작하므로 Git for Windows는 선택 사항입니다.

터미널에서 사용할 클라이언트가 실행되는지 먼저 확인합니다.

```bash
claude --version
codex --version
agy plugin list
```

전부 설치할 필요는 없습니다. 자신이 쓰는 클라이언트 부분만 따라 하면 됩니다.

## 2. 설치

### Claude Code

```bash
claude plugin marketplace add kynbeen/devkit-marketplace
claude plugin install devkit@devkit
claude plugin list
```

목록에서 `devkit@devkit`이 enabled로 나오면 설치된 것입니다. 설치에는 재시작이 필요하지
않습니다. Claude Code가 `Run /reload-plugins to activate.`라고 안내할 때만 실행 중인 세션에서
`/reload-plugins`를 실행하세요. 어느 쪽이든 `/devkit:` 을 입력하면 일곱 개 워크플로가 보입니다.

설치된 구성 요소를 직접 확인하려면:

```bash
claude plugin details devkit
```

`Skills (7)`에 `backlog, clarify, handoff, help, prefs, resume, spec`이 나오면 정상입니다.

### Codex CLI

```bash
codex plugin marketplace add kynbeen/devkit-marketplace
codex plugin add devkit@devkit
codex plugin list
```

목록에서 `devkit@devkit`이 installed, enabled로 나오면 설치된 것입니다. 새 스레드를 열어야
스킬과 세션 시작 훅이 적용됩니다.

플러그인이나 훅을 처음 활성화할 때 신뢰 확인이 나오면 표시된 저장소와 훅 내용을 읽고 승인합니다.
devkit 훅은 세션 시작과 프롬프트 제출 때 Markdown 지침을 읽어 현재 대화에 추가합니다.

### Antigravity

Antigravity(`agy`)는 GitHub marketplace 등록을 지원하지 않습니다. 저장소를 클론하고 패키지
디렉터리를 직접 지정해 설치합니다.

```bash
git clone https://github.com/kynbeen/devkit-marketplace
cd devkit-marketplace
agy plugin validate plugins/devkit
agy plugin install plugins/devkit
agy plugin enable devkit
agy plugin list
```

`agy plugin validate`가 `commands : 7 processed (converted to skills)`와 `hooks : 1 processed`를
보고하면 패키지가 정상입니다. `agy plugin list`의 `devkit` 항목에 `commands`와 `hooks`가 나오면
설치된 것입니다. Antigravity는 `commands/`의 일곱 개를 자기 스킬로 변환해 읽고, Codex 전용
어댑터 디렉터리는 읽지 않습니다. 새 세션부터 적용됩니다.

## 3. 첫 사용

설치 후 도움말부터 불러오면 현재 상황에 맞는 워크플로 하나를 추천합니다.

```text
# Claude Code
/devkit:help

# Codex
$devkit-help
```

가장 흔한 시작은 막연한 요청을 구체화하는 것입니다.

```text
# Claude Code
/devkit:clarify 사용자들이 결제 단계에서 많이 이탈해

# Codex
$devkit-clarify 사용자들이 결제 단계에서 많이 이탈해
```

에이전트가 먼저 현재 저장소를 조사한 뒤 목표·성공 기준·범위·제약을 한 번의 질문 묶음으로
확정합니다. 결정이 끝난 뒤에는 다음처럼 명세로 남깁니다.

```text
/devkit:spec 방금 확정한 결제 이탈 개선 작업을 명세로 남겨줘
$devkit-spec 방금 확정한 결제 이탈 개선 작업을 명세로 남겨줘
```

## 4. 권장 작업 흐름

```text
clarify → spec → 실제 개발 → handoff → 새 세션의 resume
                       └ 큰 작업이면 spec 다음 backlog
```

| 워크플로 | 언제 쓰나 | 결과 |
|---|---|---|
| `clarify` | 요청이 여러 뜻으로 해석될 때 | 합의된 목표·성공 기준·범위·제약 |
| `spec` | 결정이 끝나 여러 세션에서 작업할 때 | `docs/specs/*.md` |
| `backlog` | 큰 명세를 모듈별 작업으로 나눌 때 | 사용자 승인용 백로그 |
| `handoff` | 세션·기기·에이전트를 바꾸기 전 | `docs/handoffs/*.md` |
| `resume` | 다음 세션에서 이어받을 때 | 핸드오프 검증 후 작업 재개 |
| `prefs` | 개인 작업 방식을 여러 기기에 맞출 때 | 자신의 포크에 설정·버전 반영 |

예를 들어 오늘 작업을 끝낼 때는 다음처럼 요청합니다.

```text
/devkit:handoff 현재 상태를 기록하고 다음 세션에 넘겨줘
$devkit-handoff 현재 상태를 기록하고 다음 스레드에 넘겨줘
```

다음 세션에서는 `/devkit:resume` 또는 `$devkit-resume`만 실행하면 됩니다.

## 5. 업데이트

```bash
# Claude Code
claude plugin marketplace update devkit
claude plugin update devkit@devkit

# Codex CLI
codex plugin marketplace upgrade devkit
codex plugin add devkit@devkit

# Antigravity (클론한 저장소에서)
git pull
agy plugin install plugins/devkit
```

설치와 달리 **업데이트는 적용에 재시작이 필요합니다.** `claude plugin update`가 이 점을 스스로
안내합니다. 새 Claude Code 세션, 새 Codex 스레드, 새 Antigravity 세션을 시작하세요.

## 6. 제거

```bash
# Claude Code
claude plugin uninstall devkit@devkit

# Codex CLI
codex plugin remove devkit@devkit

# Antigravity
agy plugin uninstall devkit
```

필요하면 이어서 `claude plugin marketplace remove devkit` 또는
`codex plugin marketplace remove devkit`으로 marketplace 등록도 지울 수 있습니다.

## 7. 문제 해결

### 명령이나 스킬이 보이지 않음

1. `plugin list`에서 `devkit@devkit`(Antigravity는 `devkit`)이 enabled인지 확인합니다.
2. Claude Code에서는 `/reload-plugins`를 실행합니다. 업데이트 직후라면 새 세션을 엽니다.
   Codex에서는 새 스레드를, Antigravity에서는 새 세션을 엽니다.
3. 같은 이름의 예전 로컬 devkit이 있다면 중복 설치를 제거합니다. Antigravity에서는
   `agy plugin uninstall devkit` 후 다시 설치합니다.

### `/devkit:` 에 워크플로가 열네 개로 보임

`devkit-clarify`처럼 `devkit-`이 한 번 더 붙은 항목이 같이 보인다면 0.10.0 이하 버전입니다.
그 버전은 Codex 전용 어댑터를 Claude Code도 읽는 위치에 두고 있었습니다. 업데이트하세요.

```bash
claude plugin marketplace update devkit
claude plugin update devkit@devkit
```

### Claude Code에서 Windows 훅이 실패함

훅은 `cat`으로 Markdown 파일 하나를 읽을 뿐이고, Git Bash와 PowerShell 양쪽에서 동작합니다.
그래도 실패한다면 `claude plugin details devkit`에 `Hooks (2)`가 나오는지 먼저 확인하세요.

### 개인 설정이 다른 사람 설정과 섞일까 걱정됨

공용 저장소에 직접 개인 설정을 푸시하지 않습니다. 저장소를 자신의 계정으로 포크하고 그 포크를
marketplace로 등록한 뒤 `prefs`를 사용합니다. 자세한 절차는 루트 README의 개인 설정 절을
참고합니다.

### 이 공개판에 없는 기능

무인 자동개발, 텔레그램 원격 제어, 자동개발 결과 review는 의도적으로 배포하지 않습니다.
`backlog`는 자동 실행기가 아니라 사람이나 코딩 에이전트가 처리할 작업 목록을 만듭니다.
