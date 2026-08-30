---
name: devkit-prefs
description: 사용자가 명시적으로 요청한 devkit 개인 작업 설정을 조회하거나 수정하고 버전·배포 절차까지 반영한다.
---

# 개인 작업 설정

[공통 원본 워크플로](../../commands/prefs.md)를 끝까지 읽고 그대로 따른다. 이 파일은 Claude Code와
Codex가 공유하는 단일 원본이다.

Codex에서는 `$ARGUMENTS`를 현재 사용자 요청으로 해석하고, `/devkit:<name>`은 대응하는
`$devkit-<name>` 스킬로 바꿔 읽는다. 프로젝트 전용 지침 파일은 Codex에서는 `AGENTS.md`, Claude
Code에서는 `CLAUDE.md`다. 원본의 저장 위치 판정, 버전 갱신, 커밋·푸시 및 설치본 갱신 절차를
유지하되 실제 외부 변경은 현재 사용자 요청이 부여한 권한 범위 안에서만 수행한다.
