# Shared helpers for bootstrap.ps1 and init.ps1.
# Dot-source this file before calling its functions:
#   . (Join-Path $PSScriptRoot 'lib\helpers.ps1')

function Write-Header { param([string]$Text) Write-Host "`n=== $Text ===" -ForegroundColor Cyan }
function Write-Step   { param([string]$Text) Write-Host "  -> $Text" -ForegroundColor White }
function Write-Skip   { param([string]$Text) Write-Host "  .. $Text" -ForegroundColor DarkGray }
function Write-Done   { param([string]$Text) Write-Host "  ok $Text" -ForegroundColor Green }
function Write-Warn   { param([string]$Text) Write-Host "  !! $Text" -ForegroundColor Yellow }
function Write-Fail   { param([string]$Text) Write-Host "  XX $Text" -ForegroundColor Red }


function Set-DotfileLink {
    # Replace $Target with a symlink pointing at $Source. Backs up the original if it's a real file.
    # Idempotent: if $Target is already a symlink to $Source, does nothing.
    param([string]$Source, [string]$Target)

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Skip "missing in repo: $Source"
        return
    }

    $sourceFull = (Resolve-Path -LiteralPath $Source).Path

    $parent = Split-Path -LiteralPath $Target
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if (Test-Path -LiteralPath $Target) {
        $item = Get-Item -LiteralPath $Target -Force
        if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $sourceFull) {
            Write-Skip "linked: $Target"
            return
        }
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backup = "$Target.bak.$stamp"
        Move-Item -LiteralPath $Target -Destination $backup -Force
        Write-Warn "backed up $Target -> $backup"
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Target -Target $sourceFull -ErrorAction Stop | Out-Null
        Write-Done "linked $Target"
    } catch {
        Write-Fail "could not link $Target ($($_.Exception.Message))"
        Write-Warn "is Developer Mode on? (Settings -> System -> For Developers)"
    }
}


function Get-DotfileLinks {
    # Source-of-truth list of (repo file -> live system path) pairs.
    # Used by both init.ps1 (reverse direction) and bootstrap.ps1.
    # Edit this when you add a new config to the repo.
    param([string]$Root)

    @(
        @{ Source = "$Root\config\glazewm\config.yaml";                             Target = "$env:USERPROFILE\.glzr\glazewm\config.yaml" }
        @{ Source = "$Root\config\zebar\settings.json";                             Target = "$env:USERPROFILE\.glzr\zebar\settings.json" }
        @{ Source = "$Root\config\powershell\Microsoft.PowerShell_profile.ps1";      Target = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" }
        @{ Source = "$Root\config\wezterm\wezterm.lua";                              Target = "$env:USERPROFILE\.config\wezterm\wezterm.lua" }
        @{ Source = "$Root\config\zellij\config.kdl";                              Target = "$env:APPDATA\Zellij\config\config.kdl" }
        @{ Source = "$Root\config\zellij\layouts\default.kdl";                      Target = "$env:APPDATA\Zellij\config\layouts\default.kdl" }
        @{ Source = "$Root\config\starship\starship.toml";                           Target = "$env:USERPROFILE\.config\starship.toml" }
        @{ Source = "$Root\config\spicetify\config-xpui.ini";                        Target = "$env:APPDATA\spicetify\config-xpui.ini" }
    )
}


function Install-Packages {
    param([string]$Root)
    Write-Header 'Installing packages'

    # --- Scoop buckets ---
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Fail 'scoop not on PATH. Install it first: https://scoop.sh'
        return
    }

    $bucketsFile = Join-Path $Root 'packages\scoop-buckets.txt'
    if (Test-Path -LiteralPath $bucketsFile) {
        $existing = (scoop bucket list 6>&1) | Out-String
        Get-Content -LiteralPath $bucketsFile | ForEach-Object {
            $line = $_.Trim()
            if (-not $line -or $line.StartsWith('#')) { return }
            if ($existing -match "(?m)^\s*$([regex]::Escape($line))\b") {
                Write-Skip "bucket: $line"
            } else {
                scoop bucket add $line | Out-Null
                Write-Done "bucket: $line"
            }
        }
    }

    # --- Scoop apps ---
    $scoopFile = Join-Path $Root 'packages\scoop.txt'
    if (Test-Path -LiteralPath $scoopFile) {
        $installed = (scoop list 6>&1) | Out-String
        Get-Content -LiteralPath $scoopFile | ForEach-Object {
            $line = $_.Trim()
            if (-not $line -or $line.StartsWith('#')) { return }
            $appName = ($line -split '/')[-1]
            if ($installed -match "(?m)^\s*$([regex]::Escape($appName))\s") {
                Write-Skip "scoop: $appName"
            } else {
                try { scoop install $line; Write-Done "scoop: $line" }
                catch { Write-Fail "scoop: $line ($($_.Exception.Message))" }
            }
        }
    }

    # --- Winget apps ---
    $wingetFile = Join-Path $Root 'packages\winget.txt'
    if (Test-Path -LiteralPath $wingetFile) {
        Get-Content -LiteralPath $wingetFile | ForEach-Object {
            $line = $_.Trim()
            if (-not $line -or $line.StartsWith('#')) { return }
            $check = winget list --id $line --exact --accept-source-agreements 2>$null | Out-String
            if ($check -match [regex]::Escape($line)) {
                Write-Skip "winget: $line"
            } else {
                try {
                    winget install --id $line --silent --accept-package-agreements --accept-source-agreements | Out-Null
                    Write-Done "winget: $line"
                } catch { Write-Fail "winget: $line ($($_.Exception.Message))" }
            }
        }
    }

    # --- PowerShell modules ---
    $psModFile = Join-Path $Root 'packages\psmodules.txt'
    if (Test-Path -LiteralPath $psModFile) {
        Get-Content -LiteralPath $psModFile | ForEach-Object {
            $line = $_.Trim()
            if (-not $line -or $line.StartsWith('#')) { return }
            if (Get-Module -ListAvailable -Name $line) {
                Write-Skip "psmodule: $line"
            } else {
                try {
                    Install-Module $line -Scope CurrentUser -Force -AcceptLicense | Out-Null
                    Write-Done "psmodule: $line"
                } catch { Write-Fail "psmodule: $line ($($_.Exception.Message))" }
            }
        }
    }
}


function Link-Configs {
    param([string]$Root)
    Write-Header 'Linking config files'
    foreach ($link in Get-DotfileLinks -Root $Root) {
        Set-DotfileLink -Source $link.Source -Target $link.Target
    }
}


function Deploy-ZebarPacks {
    # zebar refuses to serve symlinked widget files (they resolve outside the pack
    # dir and fail its path check), so zebar packs are COPIED as real files.
    # Re-run bootstrap after editing a zebar pack.
    param([string]$Root)
    Write-Header 'Deploying zebar packs (copied, not symlinked)'
    $src  = Join-Path $Root 'config\zebar'
    $dest = "$env:USERPROFILE\.glzr\zebar"
    Get-ChildItem -LiteralPath $src -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'zpack.json') } |
        ForEach-Object {
            $target = Join-Path $dest $_.Name
            if (-not (Test-Path -LiteralPath $target)) {
                New-Item -ItemType Directory -Path $target -Force | Out-Null
            }
            Copy-Item -Path (Join-Path $_.FullName '*') -Destination $target -Recurse -Force
            Write-Done "zebar pack: $($_.Name)"
        }
}
