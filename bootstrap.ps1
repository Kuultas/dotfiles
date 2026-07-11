#Requires -Version 7
<#
.SYNOPSIS
    Reproduce my Windows ricing setup on this machine.

.DESCRIPTION
    1. Install packages declared in packages/ (scoop, winget, pwsh modules).
    2. Symlink files in config/ to their expected live locations on the system,
       backing up any existing real files first.
    3. Apply Windows registry/system tweaks from windows/tweaks.ps1.

    Idempotent: re-running is safe and skips work that's already done.

.PARAMETER SkipPackages
    Don't install scoop/winget/psmodule packages.

.PARAMETER SkipConfig
    Don't touch symlinks.

.PARAMETER SkipTweaks
    Don't run the Windows registry/system tweaks.

.EXAMPLE
    pwsh ./bootstrap.ps1

.EXAMPLE
    # Just relink configs without touching packages or system settings
    pwsh ./bootstrap.ps1 -SkipPackages -SkipTweaks
#>
[CmdletBinding()]
param(
    [switch]$SkipPackages,
    [switch]$SkipConfig,
    [switch]$SkipTweaks
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

. (Join-Path $root 'lib\helpers.ps1')

Write-Header 'dotfiles bootstrap'
Write-Host "  repo: $root"

if (-not $SkipPackages) { Install-Packages -Root $root }
if (-not $SkipConfig)   { Link-Configs    -Root $root }
if (-not $SkipTweaks) {
    $tweaks = Join-Path $root 'windows\tweaks.ps1'
    if (Test-Path -LiteralPath $tweaks) { & $tweaks }
}

Write-Host "`nDone. You may need to:" -ForegroundColor Cyan
Write-Host "  - reload GlazeWM to pick up config changes (glazewm command wm-reload-config), which also restarts zebar"
Write-Host "  - log out + in for some Explorer tweaks to settle"
