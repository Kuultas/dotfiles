# dotfiles

My Windows ricing setup. Single-command reproducible.

## On a brand new machine
```pwsh
# 1. Install pwsh 7, git, and scoop manually first
# 2. Clone this repo
git clone <your-repo-url> $env:USERPROFILE\dotfiles
cd $env:USERPROFILE\dotfiles

# 3. Enable Developer Mode (Settings -> System -> For Developers) so symlinks work without admin
# 4. Run bootstrap
pwsh ./bootstrap.ps1
```

## On an existing machine (first-time capture)
```pwsh
# 1. Capture your current live configs into the repo
pwsh ./init.ps1

# 2. Inspect everything under config/ -- this is now what gets version-controlled
# 3. Replace the live files with symlinks back to the repo
pwsh ./bootstrap.ps1
```

## Layout
```
bootstrap.ps1            entry point: install packages + symlink configs + apply tweaks
init.ps1                 one-time: capture existing system configs into this repo
packages/
  scoop-buckets.txt      scoop buckets to add
  scoop.txt              scoop apps to install (one per line, # for comments)
  winget.txt             winget package IDs
  psmodules.txt          PowerShell modules
config/                  the actual config files (live system reads them via symlinks)
windows/tweaks.ps1       registry / system tweaks
lib/helpers.ps1          shared functions
```

## Daily use
- Edit a file in `config/`, save -> live system sees it (symlink).
- New tool: append to `packages/scoop.txt`, run `bootstrap.ps1 -SkipConfig -SkipTweaks`.
- New config: drop the file in `config/<app>/`, add an entry to `Link-Configs` in `lib/helpers.ps1`, run `bootstrap.ps1`.

## Bootstrap flags
- `-SkipPackages` -- don't install anything, just relink/tweak
- `-SkipConfig` -- don't touch symlinks
- `-SkipTweaks` -- don't apply Windows registry tweaks

## Backups
Whenever bootstrap replaces a real file with a symlink, it backs up the original to `<file>.bak.<timestamp>`. These are gitignored.
