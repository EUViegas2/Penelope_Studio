# Fortran Native GView Toolchain

This folder is the project-owned home for native PENELOPE viewer work.

## Layout

- `src/gview2d/`: adapted Fortran sources for the custom `gview2d.exe`
- `src/gview3d/`: adapted Fortran sources for the custom `gview3d.exe`
- `vendor/penelope2011/`: locally fetched upstream PENELOPE 2011 sources from the existing machine install
- `bin/`: compiled executables that Penelope Studio can launch
- `build/`: compiler module/output scratch area created by the build script
- `build_gviews.ps1`: helper script that compiles whichever custom gview sources are present

## Expected workflow

1. Copy or adapt the original PENELOPE Fortran sources into `src/gview2d/` and `src/gview3d/`.
2. Apply project-specific changes there:
   - extra geometry diagnostics
   - richer `.rep` messages
   - deterministic non-interactive options
   - any Studio-friendly prompt/output changes
3. Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\fortran\build_gviews.ps1
```

4. Penelope Studio will prefer `fortran/bin/gview2d.exe` and `fortran/bin/gview3d.exe` automatically when they exist.

## Notes

- `gfortran` is available on this machine, so the missing ingredient is source ownership, not compiler setup.
- The repo now vendors the available local upstream sources:
  - `vendor/penelope2011/fsource/penelope.f`
  - `vendor/penelope2011/fsource/pengeom.f`
  - `vendor/penelope2011/fsource/material.f`
  - `vendor/penelope2011/fsource/penvared.f`
  - `vendor/penelope2011/fsource/rita.f`
  - `vendor/penelope2011/fsource/timer.f`
  - `vendor/penelope2011/mains/penmain/penmain.f`
  - `vendor/penelope2011/mains/penmain/pmcomms.f`
- The unpacked local PENELOPE 2011 install does not include `gview2d`/`gview3d` source, only the viewer executables and sample geometry files. If you have the original source archive or NEA access, those can be added later beside the vendored core files.
- The first pass build script is intentionally generic. If the adapted PENELOPE sources need a stricter compile order or extra linker flags, update `build_gviews.ps1` rather than hiding that logic elsewhere.
