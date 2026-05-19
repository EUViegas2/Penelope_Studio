# Vendored PENELOPE 2011 Sources

These files were fetched from the existing local installation at:

`C:\Users\viega\Desktop\MEBiSEL\FMIII\PENELOPE2011\PENELOPE2011`

## Included

- `fsource/material.f`
- `fsource/penelope.f`
- `fsource/pengeom.f`
- `fsource/penvared.f`
- `fsource/rita.f`
- `fsource/timer.f`
- `mains/penmain/penmain.f`
- `mains/penmain/pmcomms.f`
- `mains/penmain/penmain-layout.in`

## Not included

- Original `gview2d` / `gview3d` Fortran source was not present in the unpacked local 2011 install.
- The local install contains `gview2d.exe`, `gview3d.exe`, `gviewc.exe`, and example geometry files under `other/gview/`, but not the corresponding viewer source code.

## Intended use

These vendored files give the project a legal and practical base for building custom Studio-native Fortran tools around:

- `pengeom.f` for geometry parsing and reporting
- `penelope.f` for transport routines when needed
- `penmain.f` and `pmcomms.f` as references for how the original main program wires the core packages together
