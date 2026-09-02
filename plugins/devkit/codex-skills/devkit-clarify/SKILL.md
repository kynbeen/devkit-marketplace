---
name: devkit-clarify
description: 막연하거나 여러 해석이 가능한 개발 요청의 목표, 성공 기준, 범위와 제약을 한 번의 질문 묶음으로 구체화한다.
---

# 의도 구체화

[공통 원본 워크플로](../../commands/clarify.md)를 끝까지 읽고 그대로 따른다. 이 파일은 Claude Code,
Codex, Antigravity가 공유하는 단일 원본이다.

Codex 및 Antigravity에서는 `$ARGUMENTS`를 현재 사용자 요청으로 해석하고, `/devkit:<name>`은 대응하는
스킬(`$devkit-<name>` 또는 `devkit-<name>`)로 바꿔 읽는다. `CLAUDE.md`를 읽으라는 지시는 활성 프로젝트 지침을
읽으라는 뜻이며, Codex 및 Antigravity에서는 `AGENTS.md`를 우선한다. 원본의 질문 최소화와 실행 승인 경계를 유지한다.
