---
name: devkit-backlog
description: 확정된 명세를 사람이나 개발 에이전트가 안전하게 처리할 모듈별 백로그로 분해하고 사용자 승인용 초안을 만든다.
---

# 백로그 작성

[공통 원본 워크플로](../../commands/backlog.md)를 끝까지 읽고 그대로 따른다. 이 파일은 Claude Code,
Codex, Antigravity가 공유하는 단일 원본이다.

Codex 및 Antigravity에서는 `$ARGUMENTS`를 현재 사용자 요청으로 해석하고, `/devkit:<name>`은 대응하는
스킬(`$devkit-<name>` 또는 `devkit-<name>`)로 바꿔 읽는다. `CLAUDE.md`를 읽으라는 지시는 활성 프로젝트 지침을
읽으라는 뜻이며, Codex 및 Antigravity에서는 `AGENTS.md`를 우선한다. 실행 전에 사람이 백로그를 승인해야 한다는
원본의 안전 경계를 유지한다.
