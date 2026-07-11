# posh-git: git tab-completion (branches, remotes, subcommands).
# starship renders the git branch/status in the prompt itself, so posh-git is
# imported ONLY for completion; starship (below) owns the prompt.
Import-Module posh-git

# Starship prompt - MUST be last so it owns the prompt function.
Invoke-Expression (&starship init powershell)
