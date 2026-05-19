Place the adapted PENELOPE Fortran sources for the custom `gview2d.exe` here.

Suggested goals for the first modified build:

- accept a geometry filename from stdin or argv consistently
- emit clearer geometry-load diagnostics
- keep writing a `.rep` file even on partial/failed loads when possible
- avoid path/encoding surprises outside the original PENELOPE folder layout
