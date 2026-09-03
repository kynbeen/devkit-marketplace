---
name: devkit-spec
description: 여러 세션에 걸칠 개발 작업의 확정된 목표, 성공 기준, 범위, 제약과 접은 대안을 docs/specs에 기록한다.
---

# 작업 명세 작성

[공통 원본 워크플로](../../commands/spec.md)를 끝까지 읽고 그대로 따른다. 이 파일은 Claude Code,
Codex, Antigravity가 공유하는 단일 원본이다.

Codex 및 Antigravity에서는 `$ARGUMENTS`를 현재 사용자 요청으로 해석하고, `/devkit:<name>`은 대응하는
스킬(`$devkit-<name>` 또는 `devkit-<name>`)로 바꿔 읽는다. `CLAUDE.md`를 읽으라는 지시는 활성 프로젝트 지침을
읽으라는 뜻이며, Codex 및 Antigravity에서는 `AGENTS.md`를 우선한다. 기존 문서를 덮어쓰지 않는 규칙을 유지한다.
