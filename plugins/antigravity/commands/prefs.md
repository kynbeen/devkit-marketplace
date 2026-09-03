---
description: 개인 작업 설정(hooks/preferences.md)을 보거나 고치고, 자신의 marketplace 포크를 통해 모든 기기에 반영한다
---

사용자가 준 설명: $ARGUMENTS

이 사용자와 일하는 방식을 담은 `plugins/devkit/hooks/preferences.md`를 편집한다. 이건
**프로젝트가 아니라 사람**에 대한 설정이라 모든 리포에 적용된다.

`$ARGUMENTS`가 비어 있으면 현재 설정을 읽어 항목 목록을 보여주고 무엇을 바꿀지 묻는다.

**`$ARGUMENTS`에 자연어 요청이 있으면 되묻지 말고 5단계까지 끝까지 간다.** 문구를 다듬고,
`**왜:**`를 붙이고, 버전을 올리고, 커밋·푸시하고, 이 기기에 반영한 뒤 보고한다. "이렇게
쓸까요?"로 멈추지 않는다. 결과물을 보여주는 편이 초안을 설명하는 것보다 빠르고, 마음에 안 들면
그 자리에서 다시 고치면 된다.

되묻는 경우는 하나뿐이다: **그 항목이 여기 있을 것이 아닐 때.** 프로젝트 하나에만 해당하면 그
리포의 `AGENTS.md` 또는 `CLAUDE.md`이고, devkit의 판정 철학이면 `intent-policy.md`다. 어디로
갈지가 갈리면 그때만 묻는다.

## 0. 쓰기 가능한 marketplace 클론을 찾는다

**설치된 플러그인은 읽기 전용 캐시다.** `${CLAUDE_PLUGIN_ROOT}`나 `${PLUGIN_ROOT}` 아래 파일을
고쳐도 다음 업데이트 때 덮이고, 다른 기기에는 전달되지 않는다. 반드시 사용자가 소유한
`devkit-marketplace` 포크의 클론을 고쳐야 한다.

클론을 이 순서로 찾는다:

1. 현재 작업 디렉터리 또는 상위 디렉터리에 `.agents/plugins/marketplace.json`이 있고,
   `plugins/devkit/.claude-plugin/plugin.json` 또는 `.codex-plugin/plugin.json`의 이름이
   `devkit`인지 확인한다.
2. `DEVKIT_MARKETPLACE_ROOT` 환경변수가 있으면 그 경로를 같은 방식으로 검증한다.
3. 관례적 위치 `C:\dev\devkit-marketplace`, `~/dev/devkit-marketplace`,
   `~/devkit-marketplace`, `~/src/devkit-marketplace`를 확인한다.
4. 그래도 없으면 사용자에게 자신의 포크 클론 경로를 묻는다. 추측해서 아무 데나 쓰지 않는다.

클론을 찾았으면 쓰기 전에 다음을 확인한다:

- `git status --short`가 이해 가능한 상태인지 확인한다. 관련 없는 변경을 덮거나 함께 커밋하지 않는다.
- `git remote get-url origin`이 사용자의 포크를 가리키는지 확인한다.
- `git push --dry-run`으로 현재 브랜치에 푸시 권한이 있는지 확인한다. 실패하면 파일을 고치지 말고
  포크가 필요하다고 알린다.

클론이 없거나 upstream 저장소에 푸시 권한이 없으면, 사용자가 GitHub에서
`https://github.com/kynbeen/devkit-marketplace`를 포크하고 그 포크를 클론해야 한다고 안내한다.
개인 설정을 기기 간 동기화하려면 **처음부터 자신의 포크를 marketplace로 등록해야 한다.**

## 1. 항목을 고친다

`plugins/devkit/hooks/preferences.md`를 편집한다.

- **항목마다 `**왜:**`를 붙인다.** 근거 없는 지시는 다음 세션에 무시되거나 "개선"이라며
  지워진다.
- **프로젝트 하나에만 해당하는 건 여기 넣지 않는다.** 그건 해당 리포의 `AGENTS.md` 또는
  `CLAUDE.md`다. 판단이 애매하면 사용자에게 물어 어디로 갈지 정한다.
- **`plugins/devkit/hooks/intent-policy.md`를 건드리지 않는다.** 그건 devkit의 판정 철학이고
  이건 개인 취향이다.
- 이 파일은 매 세션 주입된다. 항목이 늘어나면 합치거나 줄일 것을 제안한다.

## 2. 버전을 올린다

아래 네 곳의 `version`을 같은 값으로 올린다.

- `plugins/devkit/.claude-plugin/plugin.json`
- `plugins/devkit/.codex-plugin/plugin.json`
- `plugins/devkit/plugin.json` (Antigravity)
- `.claude-plugin/marketplace.json`의 devkit 항목

설정만 바뀌었으면 패치 자리(`0.9.0` → `0.9.1`), 항목 구조가 바뀌었으면 마이너 자리를 올린다.
Codex의 `.agents/plugins/marketplace.json`에는 버전 필드가 없으므로 임의로 추가하지 않는다.

## 3. 커밋하고 푸시한다

```bash
git add plugins/devkit/hooks/preferences.md \
  plugins/devkit/.claude-plugin/plugin.json \
  plugins/devkit/.codex-plugin/plugin.json \
  plugins/devkit/plugin.json \
  .claude-plugin/marketplace.json
git commit -m "prefs: <무엇을 바꿨나>"
git push
```

커밋과 푸시는 직접 실행하되 무엇을 커밋했는지 사용자에게 알린다. 원격이 없거나 푸시가 실패하면
원인과 함께 알린다.

## 4. 이 기기에 반영한다

```bash
claude plugin marketplace update devkit
claude plugin update devkit@devkit
codex plugin marketplace upgrade devkit
codex plugin add devkit@devkit
```

Antigravity를 쓴다면 포크 클론에서 다시 설치한다. `agy`는 GitHub marketplace를 지원하지 않으므로
로컬 경로로만 갱신된다.

```bash
agy plugin install plugins/devkit
```

`devkit` 이름의 marketplace가 아직 등록되지 않았다면 먼저 **자신의 포크**를 등록한다.

```bash
claude plugin marketplace add <github-id>/devkit-marketplace
codex plugin marketplace add <github-id>/devkit-marketplace
```

Claude와 Codex 모두 플러그인 이름만 주면 안 된다. `@devkit`까지 붙인다. 새 버전은 새
세션이나 스레드부터 적용된다.

## 5. 보고

- 무엇을 바꿨는지
- 올린 버전과 커밋 해시, 푸시 성공 여부
- Claude Code, Codex, Antigravity 업데이트 결과

마지막에 반드시 안내한다:

> **새 설정은 다음 세션/스레드부터 적용된다.** `SessionStart` 훅은 이미 지나간 이벤트라 현재
> 세션에는 다시 주입되지 않는다.

다른 기기에서도 같은 포크 marketplace를 등록한 뒤 4단계를 실행한다.
