---
name: devkit-help
description: devkit 설치 후 첫 사용, 워크플로 선택, Claude Code와 Codex, Antigravity 호출 문법을 안내한다.
---

# devkit 도움말

[공통 원본 도움말](../../commands/help.md)을 끝까지 읽고 그대로 따른다. 이 파일은 Codex가 공통
도움말을 스킬로 발견하게 하는 얇은 어댑터다.

Codex에서는 `/devkit:<name>`을 대응하는 `$devkit-<name>` 스킬로 바꿔 읽고, 예시는 현재
사용자의 요청에 맞게 하나만 추천한다. 다른 devkit 스킬을 자동으로 실행하지 않는다.
