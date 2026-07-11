#Requires -Version 7
<#
    Idempotent Windows registry/system tweaks. Safe to re-run.
    Add new tweaks following the existing pattern: read current value,
    only write (and announce) if the change is actually needed.
#>

. (Join-Path $PSScriptRoot '..\lib\helpers.ps1')
Write-Header 'Windows tweaks'

# --- Auto-hide taskbar (you don't use it) ---
$stuck = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
if (Test-Path -LiteralPath $stuck) {
    $bytes = (Get-ItemProperty -LiteralPath $stuck).Settings
    if ($bytes[8] -ne 3) {
        $bytes[8] = 3
        Set-ItemProperty -LiteralPath $stuck -Name Settings -Value $bytes
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Write-Done 'taskbar: auto-hide enabled'
    } else {
        Write-Skip 'taskbar already auto-hide'
    }
}

# --- Explorer: show hidden files + show file extensions ---
$adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
if ((Get-ItemProperty -LiteralPath $adv).Hidden -ne 1) {
    Set-ItemProperty -LiteralPath $adv -Name Hidden -Value 1
    Write-Done 'explorer: show hidden files'
} else { Write-Skip 'hidden files already shown' }

if ((Get-ItemProperty -LiteralPath $adv).HideFileExt -ne 0) {
    Set-ItemProperty -LiteralPath $adv -Name HideFileExt -Value 0
    Write-Done 'explorer: show file extensions'
} else { Write-Skip 'extensions already shown' }

# --- Dark mode (apps + system) ---
$themes = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
if ((Get-ItemProperty -LiteralPath $themes -ErrorAction SilentlyContinue).AppsUseLightTheme -ne 0) {
    Set-ItemProperty -LiteralPath $themes -Name AppsUseLightTheme -Value 0
    Set-ItemProperty -LiteralPath $themes -Name SystemUsesLightTheme -Value 0
    Write-Done 'dark mode enabled'
} else { Write-Skip 'dark mode already on' }

# --- Developer Mode check (allows symlinks without admin) ---
$devKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
$devOn = $false
if (Test-Path -LiteralPath $devKey) {
    $devOn = (Get-ItemProperty -LiteralPath $devKey -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense -eq 1
}
if (-not $devOn) {
    Write-Warn 'Developer Mode is OFF. Symlinks will fail without admin.'
    Write-Warn 'Enable: Settings -> System -> For Developers -> Developer Mode'
} else {
    Write-Skip 'Developer Mode already on'
}
