---
name: devkit-handoff
description: 세션 종료, 컨텍스트 초기화 또는 기기·에이전트 전환 전에 현재 상태를 docs/handoffs에 기록하고 인계한다.
---

# 세션 인계

[공통 원본 워크플로](../../commands/handoff.md)를 끝까지 읽고 그대로 따른다. 이 파일은 Claude Code,
Codex, Antigravity가 공유하는 단일 원본이다.

Codex 및 Antigravity에서는 `$ARGUMENTS`를 현재 사용자 요청으로 해석하고, `/devkit:<name>`은 대응하는
스킬(`$devkit-<name>` 또는 `devkit-<name>`)로 바꿔 읽는다. Claude Code의 `/clear`는 Codex의 새 스레드/새 세션,
Antigravity의 새 세션/대화 전환으로 해석한다. `CLAUDE.md`를 읽으라는 지시는 활성 프로젝트 지침을 뜻하며 Codex 및
Antigravity에서는 `AGENTS.md`를 우선한다. 커밋과 푸시 전제, 실패 보고, 코드와 인계 문서를 분리하는 규칙을 유지한다.
