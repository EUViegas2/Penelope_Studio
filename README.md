# PENELOPE Studio

Desktop editor, runner, and analysis workspace for PENELOPE geometry (`.geo`), simulation input (`.in`), and result files.

## Current Runtime

- Active app: `penelope_studio_v9_split_runs_patch_v2.py`
- No-console launcher: `Start_Penelope_Studio_V9_NoConsole.pyw`
- Desktop shortcut helper: `Create_Desktop_Shortcut.ps1`

This repository is the working CodAI folder used to develop and run the current Studio build. It is now prepared to be moved between computers with Git while keeping local runtime clutter out of version control.

## What This Repo Contains

- Studio source code and launchers
- Native `gview2d.exe` and `gview3d.exe`
- Runtime templates under `template/`
- Fortran workspace under `fortran/`
- Setup and project documentation

What is intentionally not meant to be committed:

- autosaves, logs, temporary folders, scratch work
- generated simulation outputs and dumps
- local analysis caches and batch creation logs
- archived old versions and local checkpoints

Those are handled by `.gitignore`.

## Quick Start

Clone the repo:

```powershell
git clone https://github.com/EUViegas2/Penelope_Studio.git
cd Penelope_Studio
```

Install Python dependencies:

```powershell
py -m pip install -r requirements.txt
```

Run the Studio:

```powershell
py penelope_studio_v9_split_runs_patch_v2.py
```

Or use the no-console launcher:

```powershell
pyw .\Start_Penelope_Studio_V9_NoConsole.pyw
```

Create a desktop shortcut from the repo root:

```powershell
powershell -ExecutionPolicy Bypass -File .\Create_Desktop_Shortcut.ps1
```

Optional direct-open usage:

```powershell
py penelope_studio_v9_split_runs_patch_v2.py path\to\file.geo path\to\file.in
```

## First-Run Notes On Another Computer

After pulling the repo on a different machine, check these in Studio Settings:

- `penmain.exe`
- `material.exe`
- native `gview2d.exe`
- native `gview3d.exe`

The app now falls back more gracefully to repo-local defaults when older saved absolute paths are missing, but machine-specific program paths may still need a one-time confirmation.

All root launch scripts are intended to be path-agnostic:

- `Start_Penelope_Studio_V9_NoConsole.pyw` runs from its own folder
- `Create_Desktop_Shortcut.ps1` resolves the launcher relative to itself

So the repo should be moved, cloned, or pulled without needing to edit hardcoded user paths in those entrypoints.

## Git Workflow

Typical flow on one computer:

```powershell
git pull
git add .
git commit -m "Describe the change"
git push
```

On another computer:

```powershell
git pull
```

If it is the first time there:

```powershell
git clone https://github.com/EUViegas2/Penelope_Studio.git
```

## Recommended Validation Before Commit

For the active runtime:

```powershell
python -m py_compile .\penelope_studio_v9_split_runs_patch_v2.py
```

For repo state:

```powershell
git status --short
```

## Repo Map

- `penelope_studio_v9_split_runs_patch_v2.py`: current active Studio runtime
- `Start_Penelope_Studio_V9_NoConsole.pyw`: launcher used for normal desktop runs
- `Create_Desktop_Shortcut.ps1`: creates a desktop shortcut to the launcher
- `template/`: template runtime files used for case creation and local runs
- `fortran/`: source/build workspace for native gview work
- `v9_updates.md`: compact summary of V9-facing feature changes
- `v10_prep.md`: notes about what is intentionally still kept under the V9 identity

For a fuller folder map, see [REPO_LAYOUT.md](REPO_LAYOUT.md).

## Related Docs

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [REPO_LAYOUT.md](REPO_LAYOUT.md)
- [v9_updates.md](v9_updates.md)
- [v10_prep.md](v10_prep.md)
- [fortran/README.md](fortran/README.md)

## Notes

- The repo currently tracks the active runtime directly rather than packaging it as a distributable release.
- Native executables are part of the working repository because they are needed for the current local workflow.
- Local projects, simulation case folders, and large generated outputs are expected to live outside this repo.
