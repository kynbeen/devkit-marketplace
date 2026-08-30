---
name: devkit-resume
description: 새 세션, 새 기기 또는 다른 코딩 에이전트에서 최신 핸드오프의 유효성을 확인하고 중단된 작업을 이어받는다.
---

# 작업 재개

[공통 원본 워크플로](../../commands/resume.md)를 끝까지 읽고 그대로 따른다. 이 파일은 Claude Code와
Codex가 공유하는 단일 원본이다.

Codex에서는 `$ARGUMENTS`를 현재 사용자 힌트로 해석하고, `/devkit:<name>`은 대응하는
`$devkit-<name>` 스킬로 바꿔 읽는다. `CLAUDE.md`를 읽으라는 지시는 활성 프로젝트 지침을
읽으라는 뜻이며, Codex에서는 `AGENTS.md`를 우선한다. 최신 핸드오프 하나에서 출발하되 막히면 관련
기록을 더 읽는 원본의 낡음 판정 절차를 유지한다.
