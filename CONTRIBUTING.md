# Contributing To CodAI / PENELOPE Studio

This repository is used as a live development workspace for the current PENELOPE Studio runtime.

## Commit What Matters

Good files to commit:

- `penelope_studio_v9_split_runs_patch_v2.py`
- launcher scripts
- `template/` updates
- `fortran/` source and build docs
- root documentation such as `README.md`, `v9_updates.md`, and `v10_prep.md`

Do not commit generated local clutter:

- logs
- autosaves
- scratch folders
- simulation dumps
- local case outputs
- analysis cache JSON files
- archived old versions

Those are already covered by `.gitignore`.

## Recommended Workflow

Before starting:

```powershell
git pull
```

Before committing:

```powershell
python -m py_compile .\penelope_studio_v9_split_runs_patch_v2.py
git status --short
```

Commit and publish:

```powershell
git add .
git commit -m "Short description"
git push
```

## Cross-Computer Use

This repo is meant to support the workflow:

1. work on one computer
2. commit and push
3. pull on another computer
4. continue from there

Machine-specific executable paths may still need a one-time confirmation in Studio Settings on each computer.

## Dependency Notes

Python requirements are stored in `requirements.txt`. The current app expects:

- `PySide6`
- `numpy`
- `matplotlib`
- `openpyxl`

Install them with:

```powershell
py -m pip install -r requirements.txt
```

## Scope Of This Repo

This repository is for the Studio app and its supporting runtime assets. It is not intended to be a long-term archive of simulation outputs or project-specific result folders.
