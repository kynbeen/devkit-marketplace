$ErrorActionPreference = "Stop"

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$pluginRoot = Join-Path $repositoryRoot "plugins/devkit"
$expectedWorkflows = @("backlog", "clarify", "handoff", "prefs", "resume", "spec")

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

$claudeManifest = Read-JsonFile (Join-Path $pluginRoot ".claude-plugin/plugin.json")
$codexManifest = Read-JsonFile (Join-Path $pluginRoot ".codex-plugin/plugin.json")
$claudeMarketplace = Read-JsonFile (Join-Path $repositoryRoot ".claude-plugin/marketplace.json")
$codexMarketplace = Read-JsonFile (Join-Path $repositoryRoot ".agents/plugins/marketplace.json")

Assert-Condition ($claudeManifest.name -eq "devkit") "Claude plugin name must be devkit."
Assert-Condition ($codexManifest.name -eq "devkit") "Codex plugin name must be devkit."
Assert-Condition ($claudeMarketplace.plugins.Count -eq 1) "Claude marketplace must contain one plugin."
Assert-Condition ($codexMarketplace.plugins.Count -eq 1) "Codex marketplace must contain one plugin."
Assert-Condition ($claudeMarketplace.plugins[0].source -eq "./plugins/devkit") "Unexpected Claude marketplace source."
Assert-Condition ($codexMarketplace.plugins[0].source.path -eq "./plugins/devkit") "Unexpected Codex marketplace source."

$versions = @(@(
    [string]$claudeManifest.version,
    [string]$codexManifest.version,
    [string]$claudeMarketplace.plugins[0].version
) | Select-Object -Unique)
Assert-Condition ($versions.Count -eq 1) "Claude, Codex, and marketplace versions must match."

$commands = Get-LeafNames (Join-Path $pluginRoot "commands") "File"
$skills = Get-LeafNames (Join-Path $pluginRoot "skills") "Directory"
Assert-Condition (($commands -join ',') -eq ($expectedWorkflows -join ',')) "Unexpected command set: $($commands -join ', ')"
Assert-Condition (($skills -join ',') -eq ($expectedWorkflows -join ',')) "Unexpected skill set: $($skills -join ', ')"

$forbiddenPaths = @(
    "commands/review.md",
    "skills/devkit-review",
    "tools/autodev",
    "tools/bridge"
)
foreach ($relativePath in $forbiddenPaths) {
    Assert-Condition (-not (Test-Path -LiteralPath (Join-Path $pluginRoot $relativePath))) "Excluded path is present: $relativePath"
}

foreach ($workflow in $expectedWorkflows) {
    $skillPath = Join-Path $pluginRoot "skills/devkit-$workflow/SKILL.md"
    Assert-Condition (Test-Path -LiteralPath $skillPath -PathType Leaf) "Missing skill: devkit-$workflow"
    $skillText = Get-Content -LiteralPath $skillPath -Raw -Encoding UTF8
    Assert-Condition ($skillText.Contains("../../commands/$workflow.md")) "Skill does not link to its command: devkit-$workflow"
}

Write-Host "PASS: devkit $($versions[0]) contains exactly the six supported workflows."
