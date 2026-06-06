<#
.SYNOPSIS
    Check or synchronize the dual skill entrypoints used by Codex and Claude Code.

.DESCRIPTION
    This repository keeps two skill entrypoints:

    - .agents/skills/  for Codex
    - .claude/skills/  for Claude Code

    They are dual entrypoints, not a default one-way mirror. By default this script
    only checks whether the two directories are identical. Synchronization requires
    an explicit source direction so accidental overwrites are harder to make.

.PARAMETER Mode
    Check only, or synchronize in an explicit direction. Default: Check.

.PARAMETER From
    Source side when Mode is Sync. Use "agents" to copy .agents/skills to
    .claude/skills, or "claude" for the reverse.

.PARAMETER Force
    Required for Mode Sync. This is an explicit acknowledgement that the target
    skills directory will be replaced by the source skills directory.

.PARAMETER ExcludeDirs
    Directory names or wildcard patterns to ignore. Default: *-workspace.

.EXAMPLE
    pwsh scripts/sync_skills.ps1
    # Check whether .agents/skills and .claude/skills match.

.EXAMPLE
    pwsh scripts/sync_skills.ps1 -Mode Sync -From agents -Force
    # Replace .claude/skills with .agents/skills.

.EXAMPLE
    pwsh scripts/sync_skills.ps1 -Mode Sync -From claude -Force
    # Replace .agents/skills with .claude/skills.
#>
[CmdletBinding()]
param(
    [ValidateSet("Check", "Sync")]
    [string]$Mode = "Check",

    [ValidateSet("agents", "claude")]
    [string]$From,

    [switch]$Force,

    [string[]]$ExcludeDirs = @("*-workspace")
)

$ErrorActionPreference = "Stop"

function Get-RelativePathPortable {
    param(
        [Parameter(Mandatory = $true)][string]$BasePath,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $base = [System.IO.Path]::GetFullPath($BasePath).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $full = [System.IO.Path]::GetFullPath($Path)

    if ($full.StartsWith($base)) {
        return $full.Substring($base.Length).TrimStart([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    }

    return $full
}

function Test-ExcludedPath {
    param(
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string[]]$Patterns
    )

    if ([string]::IsNullOrWhiteSpace($RelativePath)) {
        return $false
    }

    $parts = $RelativePath -split "[/\\]+"
    foreach ($part in $parts) {
        foreach ($pattern in $Patterns) {
            if ($part -like $pattern) {
                return $true
            }
        }
    }

    return $false
}

function Get-SkillFileMap {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string[]]$ExcludeDirs
    )

    if (-not (Test-Path $Root)) {
        throw "Skills directory does not exist: $Root"
    }

    $map = @{}
    Get-ChildItem -Path $Root -Recurse -File | ForEach-Object {
        $relative = Get-RelativePathPortable -BasePath $Root -Path $_.FullName
        if (Test-ExcludedPath -RelativePath $relative -Patterns $ExcludeDirs) {
            return
        }

        $normalized = $relative -replace "\\", "/"
        $hash = Get-FileHash -Algorithm SHA256 -Path $_.FullName
        $map[$normalized] = $hash.Hash
    }

    return $map
}

function Compare-SkillTrees {
    param(
        [Parameter(Mandatory = $true)][string]$AgentsRoot,
        [Parameter(Mandatory = $true)][string]$ClaudeRoot,
        [Parameter(Mandatory = $true)][string[]]$ExcludeDirs
    )

    $agents = Get-SkillFileMap -Root $AgentsRoot -ExcludeDirs $ExcludeDirs
    $claude = Get-SkillFileMap -Root $ClaudeRoot -ExcludeDirs $ExcludeDirs
    $allPaths = @($agents.Keys + $claude.Keys) | Sort-Object -Unique
    $diffs = @()

    foreach ($path in $allPaths) {
        $inAgents = $agents.ContainsKey($path)
        $inClaude = $claude.ContainsKey($path)

        if (-not $inAgents) {
            $diffs += [pscustomobject]@{ Status = "OnlyInClaude"; Path = $path }
        } elseif (-not $inClaude) {
            $diffs += [pscustomobject]@{ Status = "OnlyInAgents"; Path = $path }
        } elseif ($agents[$path] -ne $claude[$path]) {
            $diffs += [pscustomobject]@{ Status = "Different"; Path = $path }
        }
    }

    return $diffs
}

function Copy-SkillTree {
    param(
        [Parameter(Mandatory = $true)][string]$SourceRoot,
        [Parameter(Mandatory = $true)][string]$TargetRoot,
        [Parameter(Mandatory = $true)][string[]]$ExcludeDirs
    )

    if (-not (Test-Path $SourceRoot)) {
        throw "Source skills directory does not exist: $SourceRoot"
    }

    if (Test-Path $TargetRoot) {
        Remove-Item -Path $TargetRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $TargetRoot -Force | Out-Null

    Get-ChildItem -Path $SourceRoot -Recurse | ForEach-Object {
        $relative = Get-RelativePathPortable -BasePath $SourceRoot -Path $_.FullName
        if (Test-ExcludedPath -RelativePath $relative -Patterns $ExcludeDirs) {
            return
        }

        $targetPath = Join-Path $TargetRoot $relative
        if ($_.PSIsContainer) {
            New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        } else {
            $targetDir = Split-Path -Parent $targetPath
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            Copy-Item -Path $_.FullName -Destination $targetPath -Force
        }
    }
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$AgentsRoot = Join-Path $RepoRoot ".agents/skills"
$ClaudeRoot = Join-Path $RepoRoot ".claude/skills"

Write-Host ("=== skill entrypoint check ({0}) ===" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")) -ForegroundColor Cyan
Write-Host ("Repo:   {0}" -f $RepoRoot)
Write-Host ("Codex:  {0}" -f $AgentsRoot)
Write-Host ("Claude: {0}" -f $ClaudeRoot)
Write-Host ("Exclude dirs: {0}" -f ($ExcludeDirs -join ", "))

$diffs = Compare-SkillTrees -AgentsRoot $AgentsRoot -ClaudeRoot $ClaudeRoot -ExcludeDirs $ExcludeDirs

if ($Mode -eq "Check") {
    if ($diffs.Count -eq 0) {
        Write-Host "Skills are in sync." -ForegroundColor Green
        exit 0
    }

    Write-Host ("Skills differ ({0} file differences):" -f $diffs.Count) -ForegroundColor Yellow
    $diffs | Select-Object -First 200 | Format-Table -AutoSize
    if ($diffs.Count -gt 200) {
        Write-Host ("... {0} more differences omitted" -f ($diffs.Count - 200)) -ForegroundColor Yellow
    }
    Write-Host "Run with -Mode Sync -From agents -Force or -Mode Sync -From claude -Force after choosing a source." -ForegroundColor Yellow
    exit 2
}

if ([string]::IsNullOrWhiteSpace($From)) {
    Write-Error "Mode Sync requires -From agents or -From claude."
    exit 1
}

if (-not $Force) {
    Write-Error "Mode Sync replaces the target skills directory. Re-run with -Force after choosing the source intentionally."
    exit 1
}

if ($From -eq "agents") {
    Write-Host "Syncing .agents/skills -> .claude/skills" -ForegroundColor Cyan
    Copy-SkillTree -SourceRoot $AgentsRoot -TargetRoot $ClaudeRoot -ExcludeDirs $ExcludeDirs
} else {
    Write-Host "Syncing .claude/skills -> .agents/skills" -ForegroundColor Cyan
    Copy-SkillTree -SourceRoot $ClaudeRoot -TargetRoot $AgentsRoot -ExcludeDirs $ExcludeDirs
}

$postDiffs = Compare-SkillTrees -AgentsRoot $AgentsRoot -ClaudeRoot $ClaudeRoot -ExcludeDirs $ExcludeDirs
if ($postDiffs.Count -eq 0) {
    Write-Host "Sync complete. Skills are in sync." -ForegroundColor Green
    exit 0
}

Write-Host ("Sync completed but {0} differences remain:" -f $postDiffs.Count) -ForegroundColor Yellow
$postDiffs | Select-Object -First 200 | Format-Table -AutoSize
exit 2
