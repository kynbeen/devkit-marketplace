[CmdletBinding()]
param(
    [ValidateSet("Check", "Apply")]
    [string]$Mode = "Check",

    [string]$SourceRoot,

    [string]$Version,

    [switch]$AcceptAdapted
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
$OutputEncoding = [Text.UTF8Encoding]::new()

$marketplaceRoot = Split-Path -Parent $PSScriptRoot
$pluginRoot = Join-Path $marketplaceRoot "plugins/devkit"
$statePath = Join-Path $marketplaceRoot "sync/devkit-source.json"
$state = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json

if (-not $SourceRoot) {
    $SourceRoot = Join-Path $marketplaceRoot $state.sourceRepository
}
$SourceRoot = [IO.Path]::GetFullPath($SourceRoot)

function Assert-Condition {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Get-GitOutput {
    param([string]$Repository, [string[]]$Arguments)
    $output = & git -C $Repository @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Git command failed in $Repository`: git $($Arguments -join ' ')"
    }
    return @($output)
}

function Get-TargetRelativePath {
    param([string]$RelativePath)
    if ($null -ne $state.pathRewrites) {
        foreach ($rewrite in $state.pathRewrites.PSObject.Properties) {
            if ($RelativePath.StartsWith($rewrite.Name)) {
                return $rewrite.Value + $RelativePath.Substring($rewrite.Name.Length)
            }
        }
    }
    return $RelativePath
}

function Get-Hash {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Write-JsonFile {
    param([string]$Path, [object]$Value)
    $json = $Value | ConvertTo-Json -Depth 20
    [IO.File]::WriteAllText($Path, $json + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
}

Assert-Condition (Test-Path -LiteralPath (Join-Path $SourceRoot ".git")) "devkit Git 저장소가 아닙니다: $SourceRoot"
Assert-Condition (Test-Path -LiteralPath (Join-Path $marketplaceRoot ".git")) "marketplace Git 저장소가 아닙니다: $marketplaceRoot"

$sourceCommit = @(Get-GitOutput $SourceRoot @("rev-parse", "HEAD"))[0]
$sourceDirty = Get-GitOutput $SourceRoot @("status", "--porcelain", "--untracked-files=all")
$targetDirty = Get-GitOutput $marketplaceRoot @("status", "--porcelain", "--untracked-files=all")

$verbatimDrift = @()
foreach ($relativePath in $state.verbatimFiles) {
    $sourcePath = Join-Path $SourceRoot $relativePath
    $targetPath = Join-Path $pluginRoot (Get-TargetRelativePath $relativePath)
    if ((Get-Hash $sourcePath) -ne (Get-Hash $targetPath)) {
        $verbatimDrift += $relativePath
    }
}

$adaptedDrift = @()
foreach ($property in $state.adaptedFiles.PSObject.Properties) {
    $sourcePath = Join-Path $SourceRoot $property.Name
    if ((Get-Hash $sourcePath) -ne $property.Value) {
        $adaptedDrift += $property.Name
    }
}

$excludedPresent = @()
foreach ($relativePath in $state.excludedPaths) {
    foreach ($candidate in @($relativePath, (Get-TargetRelativePath $relativePath)) | Select-Object -Unique) {
        if (Test-Path -LiteralPath (Join-Path $pluginRoot $candidate)) {
            $excludedPresent += $candidate
        }
    }
}

if ($Mode -eq "Check") {
    Write-Output "Source commit: $sourceCommit"
    Write-Output "Verbatim drift: $($verbatimDrift.Count)"
    $verbatimDrift | ForEach-Object { Write-Output "  COPY NEEDED: $_" }
    Write-Output "Adapted drift: $($adaptedDrift.Count)"
    $adaptedDrift | ForEach-Object { Write-Output "  MANUAL REVIEW: $_" }
    Write-Output "Excluded paths present: $($excludedPresent.Count)"

    Assert-Condition ($verbatimDrift.Count -eq 0) "원본과 그대로 동기화할 파일에 차이가 있습니다. -Mode Apply로 반영하세요."
    Assert-Condition ($adaptedDrift.Count -eq 0) "배포용 어댑터의 원본이 바뀌었습니다. 수동 반영 후 -AcceptAdapted가 필요합니다."
    Assert-Condition ($excludedPresent.Count -eq 0) "배포 제외 경로가 marketplace 패키지에 들어왔습니다."
    Write-Output "PASS: devkit source and marketplace are synchronized within the publication boundary."
    exit 0
}

Assert-Condition ($sourceDirty.Count -eq 0) "원본 devkit 작업 트리가 깨끗하지 않습니다. 먼저 커밋하거나 되돌리세요."
Assert-Condition ($targetDirty.Count -eq 0) "marketplace 작업 트리가 깨끗하지 않습니다. 기존 변경을 먼저 처리하세요."
Assert-Condition ($excludedPresent.Count -eq 0) "배포 제외 경로가 marketplace 패키지에 들어왔습니다."
Assert-Condition (-not [string]::IsNullOrWhiteSpace($Version)) "Apply에는 새 배포 버전(-Version)이 필요합니다."
Assert-Condition ($Version -match '^\d+\.\d+\.\d+$') "버전은 1.2.3 형식의 안정 SemVer여야 합니다."
if ($adaptedDrift.Count -gt 0 -and -not $AcceptAdapted) {
    throw "배포용 어댑터의 원본이 바뀌었습니다: $($adaptedDrift -join ', '). 수동 반영 후 -AcceptAdapted를 사용하세요."
}

$currentVersion = (Get-Content -LiteralPath (Join-Path $pluginRoot ".codex-plugin/plugin.json") -Raw -Encoding UTF8 | ConvertFrom-Json).version
Assert-Condition ([version]$Version -gt [version]$currentVersion) "새 버전은 현재 버전 $currentVersion 보다 커야 합니다."

foreach ($relativePath in $state.verbatimFiles) {
    $sourcePath = Join-Path $SourceRoot $relativePath
    $targetPath = Join-Path $pluginRoot (Get-TargetRelativePath $relativePath)
    Assert-Condition (Test-Path -LiteralPath $sourcePath -PathType Leaf) "원본 파일이 없습니다: $relativePath"
    New-Item -ItemType Directory -Path (Split-Path -Parent $targetPath) -Force | Out-Null
    Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
}

$claudeManifestPath = Join-Path $pluginRoot ".claude-plugin/plugin.json"
$codexManifestPath = Join-Path $pluginRoot ".codex-plugin/plugin.json"
$claudeMarketplacePath = Join-Path $marketplaceRoot ".claude-plugin/marketplace.json"
$claudeManifest = Get-Content -LiteralPath $claudeManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$codexManifest = Get-Content -LiteralPath $codexManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$claudeMarketplace = Get-Content -LiteralPath $claudeMarketplacePath -Raw -Encoding UTF8 | ConvertFrom-Json
$claudeManifest.version = $Version
$codexManifest.version = $Version
$claudeMarketplace.plugins[0].version = $Version
Write-JsonFile $claudeManifestPath $claudeManifest
Write-JsonFile $codexManifestPath $codexManifest
Write-JsonFile $claudeMarketplacePath $claudeMarketplace

$state.sourceCommit = $sourceCommit
if ($AcceptAdapted) {
    foreach ($relativePath in $adaptedDrift) {
        $state.adaptedFiles.PSObject.Properties[$relativePath].Value = Get-Hash (Join-Path $SourceRoot $relativePath)
    }
}
Write-JsonFile $statePath $state

# Release instructions carry a copy-pasteable version number. Left alone it falls behind the
# release it documents, and the -Version guard above then rejects the very command the docs tell
# you to run. Push the examples one minor ahead of what was just published.
$applied = [version]$Version
$exampleVersion = "$($applied.Major).$($applied.Minor + 1).0"
$examplePatterns = @(
    '(?<=-Version )\d+\.\d+\.\d+',
    '(?<=sync devkit release )\d+\.\d+\.\d+'
)
$exampleDocuments = @(
    (Join-Path $marketplaceRoot "docs/MAINTAINING.md"),
    (Join-Path $marketplaceRoot "README.md")
)
foreach ($documentPath in $exampleDocuments) {
    Assert-Condition (Test-Path -LiteralPath $documentPath -PathType Leaf) "릴리스 예시를 담은 문서가 없습니다: $documentPath"
    $original = [IO.File]::ReadAllText($documentPath)
    $updated = $original
    foreach ($pattern in $examplePatterns) {
        $updated = [Text.RegularExpressions.Regex]::Replace($updated, $pattern, $exampleVersion)
    }
    if ($updated -ne $original) {
        [IO.File]::WriteAllText($documentPath, $updated, [Text.UTF8Encoding]::new($false))
        Write-Output "Release examples now read $exampleVersion in $([IO.Path]::GetFileName($documentPath))."
    }
}

& (Join-Path $PSScriptRoot "validate.ps1")
if ($LASTEXITCODE -ne 0) { throw "marketplace 검증에 실패했습니다." }

Write-Output "Applied devkit $sourceCommit to marketplace version $Version."
Write-Output "Review the diff, commit, push, and update both clients."
