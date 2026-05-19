# V10 Prep Notes

Last updated: 2026-05-12

## Current active runtime

- App file: `penelope_studio_v9_split_runs_patch_v2.py`
- Launcher: `Start_Penelope_Studio_V9_NoConsole.pyw`
- Native viewers expected at runtime:
  - `gview2d.exe`
  - `gview3d.exe`
  - `template/` executables for case creation and simulation runs

## Validated incoherencies resolved

- Root no-console launcher now points to `penelope_studio_v9_split_runs_patch_v2.py`.
- Root docs now mark patch-v2 as the current active runtime instead of `penelope_studio_v9.py`.
- Patch-v2 top-level usage text now points to its own filename.

## Intentionally deferred until true V10 cutover

- `APP_VERSION` remains `V9`.
- Shared settings identity remains `CodAI / PenelopeStudio`.
- Legacy settings fallback still includes `PenelopeStudioV9` and `PenelopeStudioV8`.
- Single-instance mutex and temp-folder names still use `V9`.
- Launcher and shortcut filenames still use `V9`.

These were left stable on purpose so settings, reopen behavior, and single-instance
protection do not reset before the real V10 rename.

## Root cleanup target

Keep in root only what is needed to run the current Studio build and the native viewers:

- `penelope_studio_v9_split_runs_patch_v2.py`
- `Start_Penelope_Studio_V9_NoConsole.pyw`
- `Create_Desktop_Shortcut.ps1`
- `gview2d.exe`
- `gview3d.exe`
- `scone_angles_help.png`
- `requirements.txt`
- `README.md`
- `v9_updates.md`
- `v10_prep.md`
- runtime-support folders such as `template/`, `fortran/`, `logs/`, and the local environment folders

Older scripts, loose sample/test files, recovery artifacts, and temporary test folders
should live in archive folders instead of the runnable root.
