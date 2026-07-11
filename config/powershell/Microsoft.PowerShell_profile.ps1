function global:git {
    Remove-Item -Path Function:git -Force -ErrorAction SilentlyContinue
    Import-Module posh-git
    & git @args
}

# Claude Code multi-account functions
function claude1 { claude $args }
function claude2 {
    $env:CLAUDE_CONFIG_DIR = "$env:USERPROFILE\.claude-account2"
    try { claude @args } finally { Remove-Item Env:\CLAUDE_CONFIG_DIR -ErrorAction SilentlyContinue }
}

# --- Starship prompt ---
Invoke-Expression (&starship init powershell)