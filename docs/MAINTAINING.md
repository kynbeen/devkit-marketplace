# 원본 devkit과 marketplace 동기화

두 저장소는 완전한 양방향 미러가 아닙니다. `C:\dev\devkit`은 개인용 전체 기능의 원본이고,
이 저장소는 공개 가능한 축소 배포본입니다. 따라서 안전한 방향은 **원본 → marketplace 단방향
발행 동기화**입니다.

양방향 자동 병합을 하지 않는 이유는 marketplace에서 의도적으로 제거한 자동개발·텔레그램·review가
다시 들어오거나, 공개판 전용 `backlog`·`prefs` 어댑터가 원본을 덮을 수 있기 때문입니다.

## 파일 정책

정확한 목록과 마지막 대조 상태는 [`sync/devkit-source.json`](../sync/devkit-source.json)에 있습니다.

- `verbatimFiles`: 원본을 그대로 복사해도 되는 공통 워크플로·훅
- `adaptedFiles`: 원본 변경을 감지하되 공개판에 맞게 사람이 반영해야 하는 파일
- `excludedPaths`: 공개 패키지에 절대 들어오면 안 되는 경로
- `marketplaceOnlyPaths`: 도움말과 호스트 manifest 등 공개판이 소유하는 파일
- `pathRewrites`: 원본과 배포본의 디렉터리 이름이 다른 경우의 대응표

경로 목록은 모두 **원본 devkit 기준**으로 적습니다. 원본은 Codex 어댑터를 `skills/`에 두지만
배포본은 `codex-skills/`에 둡니다(이유는 [아키텍처 설명](ARCHITECTURE.md) 참고). 두 스크립트가
`pathRewrites`를 읽어 복사·검사 대상 경로를 자동으로 바꾸므로, 목록에 배포본 경로를 직접 적지
않습니다.

## 차이만 확인

저장소 두 개가 `C:\dev` 아래 형제 디렉터리에 있으면 다음만 실행합니다.

```powershell
pwsh -File scripts/sync-from-devkit.ps1
```

다른 위치라면 원본 경로를 지정합니다.

```powershell
pwsh -File scripts/sync-from-devkit.ps1 -SourceRoot D:\src\devkit
```

그대로 복사할 파일의 차이, 수동 검토가 필요한 어댑터 원본 변화, 제외 경로 침입을 각각
보고합니다. `Check` 모드는 파일을 바꾸지 않습니다.

## 새 버전으로 반영

1. 원본과 marketplace 작업 트리를 모두 커밋해 깨끗하게 만듭니다.
2. 먼저 Check 결과에서 `MANUAL REVIEW`가 있는지 봅니다.
3. 있으면 대응하는 공개판 어댑터를 수동으로 고쳐 배포 경계를 유지합니다.
4. 새 SemVer와 함께 Apply를 실행합니다.

```powershell
pwsh -File scripts/sync-from-devkit.ps1 -Mode Apply -Version 1.1.0
```

수동 어댑터 반영을 완료했다면 그 사실을 명시적으로 승인합니다.

```powershell
pwsh -File scripts/sync-from-devkit.ps1 -Mode Apply -Version 1.1.0 -AcceptAdapted
```

Apply는 다음을 한 번에 수행합니다.

- `verbatimFiles`만 원본에서 복사
- Claude·Codex manifest와 Claude marketplace 버전을 같은 값으로 변경
- 대조한 원본 커밋을 동기화 상태에 기록
- 이 문서와 README의 **릴리스 예시 버전**을 방금 낸 버전보다 한 마이너 위로 변경
- 배포 구조 검증 실행

예시 버전을 자동으로 미는 이유는, 위 명령들이 복붙용이라 숫자가 박혀 있고 Apply가
`새 버전 > 현재 버전`을 요구하기 때문입니다. 그대로 두면 **문서가 시키는 명령이 문서가 설명한
검사에 걸린다.** 그래서 diff에 이 문서와 README의 예시 줄이 함께 잡히는 것은 정상입니다.

그 뒤 변경 내용을 검토하고 커밋·푸시합니다.

```powershell
git diff --check
git diff
pwsh -File scripts/validate.ps1
claude plugin validate .
git add -A
git commit -m "chore: sync devkit release 1.1.0"
git push
```

실제 설치 검증 뒤 사용자에게는 업데이트 명령과 새 세션을 열어야 한다는 점을 안내합니다.
