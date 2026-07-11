#Requires -Version 7
<#
.SYNOPSIS
    Capture your current live configs INTO this repo so they can be version-controlled.

.DESCRIPTION
    Run this ONCE on a system that already has your customizations applied.
    For each known config, if the live file exists and the repo doesn't already
    have one, copies it into config/<app>/.

    Never overwrites repo files (re-run safe).
    Never touches live files (no symlinks created here -- that's bootstrap.ps1's job).

    After this finishes:
      1. Inspect config/ -- this is what will be version-controlled.
      2. git init / commit / push.
      3. Run bootstrap.ps1 to replace the live files with symlinks back to the repo.
#>

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
. (Join-Path $root 'lib\helpers.ps1')

Write-Header 'capturing existing configs into repo'

foreach ($link in Get-DotfileLinks -Root $root) {
    $live = $link.Target
    $repo = $link.Source

    if (-not (Test-Path -LiteralPath $live)) {
        Write-Skip "not on system: $live"
        continue
    }
    if (Test-Path -LiteralPath $repo) {
        Write-Skip "already in repo: $repo"
        continue
    }

    # Don't capture symlinks (would just be capturing a redirect)
    $item = Get-Item -LiteralPath $live -Force
    if ($item.LinkType -eq 'SymbolicLink') {
        Write-Skip "live file is already a symlink, skipping: $live"
        continue
    }

    $parent = Split-Path -LiteralPath $repo
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    Copy-Item -LiteralPath $live -Destination $repo
    Write-Done "captured $live"
}

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  1. Inspect config/ and remove anything you don't want tracked."
Write-Host "  2. git init && git add . && git commit -m 'initial capture'"
Write-Host "  3. pwsh ./bootstrap.ps1   # converts live files to symlinks pointing at the repo"
