# posh-git: git tab-completion (branches, remotes, subcommands).
# starship renders the git branch/status in the prompt itself, so posh-git is
# imported ONLY for completion; starship (below) owns the prompt.
Import-Module posh-git

# Claude Code multi-account switchers
function claude1 { claude $args }
function claude2 {
    $env:CLAUDE_CONFIG_DIR = "$env:USERPROFILE\.claude-account2"
    try { claude @args } finally { Remove-Item Env:\CLAUDE_CONFIG_DIR -ErrorAction SilentlyContinue }
}

# Starship prompt - MUST be last so it owns the prompt function.
Invoke-Expression (&starship init powershell)
