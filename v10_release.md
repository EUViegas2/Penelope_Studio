# V10 Release Notes

Last updated: 2026-06-12

## Current active runtime

- App file: `penelope_studio_v10.py`
- Launcher: `Start_Penelope_Studio_V10_NoConsole.pyw`
- Desktop shortcut helper: `Create_Desktop_Shortcut.ps1`

Compatibility entrypoints are still shipped so older shortcuts and habits do not immediately break:

- `penelope_studio_v9_split_runs_patch_v2.py`
- `Start_Penelope_Studio_V9_NoConsole.pyw`

## V10 cutover

This release promotes the previously active patch-v2 runtime into the V10 line.

Included in the cutover:

- `APP_VERSION` now reports `V10`
- the main runtime is now `penelope_studio_v10.py`
- the main no-console launcher is now `Start_Penelope_Studio_V10_NoConsole.pyw`
- the desktop shortcut helper now creates `PENELOPE Studio V10.lnk`
- mutex, temp-folder, lock-file, and gview temp paths now use the V10 identity
- root documentation now points to the V10 runtime and launcher

## Settings and compatibility behavior

- Shared settings identity remains `CodAI / PenelopeStudio`
- Legacy settings fallback still includes `PenelopeStudioV9` and `PenelopeStudioV8`
- Older V9-named entrypoints now forward to V10 instead of breaking

This keeps upgrades smoother across machines while still making the release identity explicit.

## Functional highlights included in this release line

- expanded batch and workbook analysis workflow
- richer MATLAB dose-analysis generation
- improved 3D-dose browsing and grouped analysis support
- cleaner component totals export flow
- broader batch/case creation and renumbering tooling
- stronger GUI behavior around tooltips, dialogs, and monitor restore

## Root runtime set

Keep in root what is needed to run the current Studio build and the native viewers:

- `penelope_studio_v10.py`
- `Start_Penelope_Studio_V10_NoConsole.pyw`
- `Create_Desktop_Shortcut.ps1`
- compatibility shims for the V9 entrypoints
- `gview2d.exe`
- `gview3d.exe`
- `scone_angles_help.png`
- `requirements.txt`
- `README.md`
- `v10_release.md`
- `v9_updates.md`
- runtime-support folders such as `template/`, `fortran/`, and local runtime folders
