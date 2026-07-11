# dotfiles

Windows ricing. `bootstrap.ps1` installs `packages/`, symlinks `config/`, and applies `windows/tweaks.ps1` — idempotent; `Get-Help ./bootstrap.ps1` for flags.

Non-obvious:
- `config/` is **symlinked** into place, so editing a file there is live with no re-run.
- Exception: zebar widget packs (`config/zebar/<pack>/`) are **copied**, not symlinked (zebar refuses to serve symlinked widget files) — re-run `bootstrap.ps1` after editing one.
- A new config is ignored until it's added to `Get-DotfileLinks` in `lib/helpers.ps1`.
- Symlink creation needs **Developer Mode** (Settings → System → For Developers), otherwise an admin shell.
- `init.ps1` is the reverse: captures already-live configs into `config/` (one-time, on a machine that's already set up).
