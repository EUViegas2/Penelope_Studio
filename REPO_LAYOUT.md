# Repo Layout

This file describes the root structure that is meant to stay Git-friendly.

## Root Runtime Files

- `penelope_studio_v9_split_runs_patch_v2.py`
  - current active Studio runtime
- `Start_Penelope_Studio_V9_NoConsole.pyw`
  - normal no-console launcher
- `Create_Desktop_Shortcut.ps1`
  - helper to create a desktop shortcut
- `requirements.txt`
  - Python dependencies for the current runtime
- `README.md`
  - main repo entrypoint
- `CONTRIBUTING.md`
  - commit and workflow notes
- `REPO_LAYOUT.md`
  - this file
- `v9_updates.md`
  - compact change summary
- `v10_prep.md`
  - current V10 preparation notes

## Native Runtime Assets

- `gview2d.exe`
- `gview3d.exe`
- `scone_angles_help.png`

These are kept at the root because the current Studio workflow uses them directly.

## Runtime Support Folders

- `template/`
  - template files and runtime helpers used during case creation and simulation preparation
- `fortran/`
  - native gview source/build workspace

## Local-Only Folders Typically Present

These may exist locally but are not meant to be versioned:

- `logs/`
- `scratch/`
- `backups/`
- `checkpoints/`
- `reports/`
- `old versions/`
- temporary `tmp*` folders
- local test/probe folders such as `_project_test_root/`

They are ignored through `.gitignore`.

## Project Data Philosophy

The Studio application lives in this repo.

Actual simulation projects should normally live outside this repo, in their own project folders containing:

- `geometry/`
- `materials/`
- `instructions/`
- `cases/`
- `analysis/`

That keeps the Git repository focused on the app itself instead of growing with simulation output data.
