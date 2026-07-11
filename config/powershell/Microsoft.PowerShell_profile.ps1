# Starship prompt. `--print-full-init` skips starship's extra bootstrap spawn.
Invoke-Expression (&starship init powershell --print-full-init | Out-String)
