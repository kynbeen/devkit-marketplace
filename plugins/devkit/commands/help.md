---
description: devkit에서 어떤 워크플로를 언제 쓰는지 설치 후 첫 사용부터 안내한다
---

사용자가 devkit 사용법을 물었거나 어떤 워크플로를 골라야 할지 모를 때 안내한다.

## 1. 지금 필요한 워크플로를 먼저 추천한다

현재 요청을 보고 아래에서 가장 가까운 것 **하나**를 먼저 추천한다. 전부 실행하지 않는다.

| 상황 | Claude Code | Codex | 하는 일 |
|---|---|---|---|
| 요청이 아직 막연함 | `/devkit:clarify` | `$devkit-clarify` | 목표·성공 기준·범위·제약을 한 번에 확정 |
| 합의한 작업을 문서로 고정 | `/devkit:spec` | `$devkit-spec` | `docs/specs/`에 명세 작성 |
| 큰 명세를 작업 목록으로 분해 | `/devkit:backlog` | `$devkit-backlog` | 사람이 처리할 모듈별 백로그 작성 |
| 세션·기기·에이전트를 바꿈 | `/devkit:handoff` | `$devkit-handoff` | `docs/handoffs/`에 현재 상태 기록 |
| 이전 작업을 이어받음 | `/devkit:resume` | `$devkit-resume` | 최신 핸드오프를 확인하고 재개 |
| 개인 작업 방식을 바꿈 | `/devkit:prefs` | `$devkit-prefs` | 자신의 marketplace 포크에 설정 동기화 |

Antigravity에서는 같은 일곱 개가 `commands/`에서 변환된 스킬로 보인다. 표의 Claude Code 열을
기준으로 읽고 호출 문법만 현재 호스트에 맞춘다.

보통은 `clarify → spec → 실제 작업 → handoff → resume` 순서다. 작업이 여러 모듈로 나뉠 만큼
클 때만 `spec` 다음에 `backlog`를 넣는다.

## 2. 바로 쓸 수 있는 예시를 보여 준다

현재 호스트에 맞는 문법 하나만 사용한다.

```text
# Claude Code
/devkit:clarify 결제 오류를 줄이고 싶어

# Codex
$devkit-clarify 결제 오류를 줄이고 싶어
```

세션을 마칠 때는 다음처럼 요청한다.

```text
/devkit:handoff 오늘 작업을 여기서 마치고 다음 세션으로 넘겨줘
$devkit-handoff 오늘 작업을 여기서 마치고 다음 스레드로 넘겨줘
```

## 3. 배포 범위를 분명히 말한다

이 공개판에는 무인 자동개발, 텔레그램 원격 제어, review 워크플로가 없다. `backlog`는 자동
실행기가 아니라 사람이나 코딩 에이전트가 처리할 작업 목록을 만드는 기능이다.

더 자세한 설치·업데이트·문제 해결은
`https://github.com/kynbeen/devkit-marketplace/blob/main/docs/GETTING_STARTED.md`를 안내한다.
