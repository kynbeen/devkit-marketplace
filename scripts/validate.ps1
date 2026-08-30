$ErrorActionPreference = "Stop"

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$pluginRoot = Join-Path $repositoryRoot "plugins/devkit"
$expectedWorkflows = @("backlog", "clarify", "handoff", "help", "prefs", "resume", "spec")

function Assert-Condition {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Condition,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Read-JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    Assert-Condition (Test-Path -LiteralPath $Path -PathType Leaf) "Missing JSON file: $Path"
    return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Get-LeafNames {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateSet("File", "Directory")]
        [string]$Kind
    )

    if ($Kind -eq "File") {
        return @(Get-ChildItem -LiteralPath $Path -File | ForEach-Object { $_.BaseName } | Sort-Object)
    }

    return @(Get-ChildItem -LiteralPath $Path -Directory | ForEach-Object {
        $_.Name -replace '^devkit-', ''
    } | Sort-Object)
}

function Get-TargetRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath,

        [object]$Rewrites
    )

    if ($null -ne $Rewrites) {
        foreach ($rewrite in $Rewrites.PSObject.Properties) {
            if ($RelativePath.StartsWith($rewrite.Name)) {
                return $rewrite.Value + $RelativePath.Substring($rewrite.Name.Length)
            }
        }
    }

    return $RelativePath
}

$claudeManifest = Read-JsonFile (Join-Path $pluginRoot ".claude-plugin/plugin.json")
$codexManifest = Read-JsonFile (Join-Path $pluginRoot ".codex-plugin/plugin.json")
$claudeMarketplace = Read-JsonFile (Join-Path $repositoryRoot ".claude-plugin/marketplace.json")
$codexMarketplace = Read-JsonFile (Join-Path $repositoryRoot ".agents/plugins/marketplace.json")
$syncState = Read-JsonFile (Join-Path $repositoryRoot "sync/devkit-source.json")

Assert-Condition ($claudeManifest.name -eq "devkit") "Claude plugin name must be devkit."
Assert-Condition ($codexManifest.name -eq "devkit") "Codex plugin name must be devkit."
Assert-Condition ($claudeMarketplace.plugins.Count -eq 1) "Claude marketplace must contain one plugin."
Assert-Condition ($codexMarketplace.plugins.Count -eq 1) "Codex marketplace must contain one plugin."
Assert-Condition ($claudeMarketplace.plugins[0].source -eq "./plugins/devkit") "Unexpected Claude marketplace source."
Assert-Condition ($codexMarketplace.plugins[0].source.path -eq "./plugins/devkit") "Unexpected Codex marketplace source."
Assert-Condition ($syncState.verbatimFiles.Count -gt 0) "Sync state must declare verbatim files."
Assert-Condition (@($syncState.adaptedFiles.PSObject.Properties).Count -gt 0) "Sync state must declare adapted files."

$versions = @(@(
    [string]$claudeManifest.version,
    [string]$codexManifest.version,
    [string]$claudeMarketplace.plugins[0].version
) | Select-Object -Unique)
Assert-Condition ($versions.Count -eq 1) "Claude, Codex, and marketplace versions must match."

# Claude Code discovers every directory named skills/ at the plugin root and ADDS it to the
# components it already found in commands/. A skills/ directory here would therefore publish the
# Codex adapters to Claude Code as a second, duplicate set of /devkit:devkit-* commands.
Assert-Condition (-not (Test-Path -LiteralPath (Join-Path $pluginRoot "skills"))) "plugins/devkit/skills exists: Claude Code would load the Codex adapters as duplicate commands. Keep them in codex-skills/."
Assert-Condition ($codexManifest.skills -eq "./codex-skills/") "Codex manifest must point skills at ./codex-skills/."

$commands = Get-LeafNames (Join-Path $pluginRoot "commands") "File"
$codexSkills = Get-LeafNames (Join-Path $pluginRoot "codex-skills") "Directory"
Assert-Condition (($commands -join ',') -eq ($expectedWorkflows -join ',')) "Unexpected command set: $($commands -join ', ')"
Assert-Condition (($codexSkills -join ',') -eq ($expectedWorkflows -join ',')) "Unexpected Codex skill set: $($codexSkills -join ', ')"

$forbiddenPaths = @(
    "commands/review.md",
    "skills/devkit-review",
    "codex-skills/devkit-review",
    "tools/autodev",
    "tools/bridge"
)
foreach ($relativePath in $forbiddenPaths) {
    Assert-Condition (-not (Test-Path -LiteralPath (Join-Path $pluginRoot $relativePath))) "Excluded path is present: $relativePath"
}

foreach ($relativePath in $syncState.excludedPaths) {
    $targetPath = Get-TargetRelativePath $relativePath $syncState.pathRewrites
    Assert-Condition (-not (Test-Path -LiteralPath (Join-Path $pluginRoot $targetPath))) "Excluded path is present: $targetPath"
}

foreach ($workflow in $expectedWorkflows) {
    $skillPath = Join-Path $pluginRoot "codex-skills/devkit-$workflow/SKILL.md"
    Assert-Condition (Test-Path -LiteralPath $skillPath -PathType Leaf) "Missing Codex skill: devkit-$workflow"
    $skillText = Get-Content -LiteralPath $skillPath -Raw -Encoding UTF8
    Assert-Condition ($skillText.Contains("../../commands/$workflow.md")) "Codex skill does not link to its command: devkit-$workflow"
}

Write-Host "PASS: devkit $($versions[0]) publishes exactly seven Claude Code commands and seven Codex-only adapters."
