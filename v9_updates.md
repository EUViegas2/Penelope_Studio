# PENELOPE Studio V9 Updates

## Geometry labels

- Non-plane surface labels now use short type prefixes.
- Examples:
  - `cyl, c5c4 disc`
  - `sph, outer shell`
  - `par, guide`
- Plane labels keep the coordinate-driven style such as `Z=4.164 cm`.
- `Refresh` now upgrades older `.geo` files to the current label style automatically.

## Geometry editor

- Hovering `SURFACE (...)`, `BODY (...)`, or `MODULE (...)` references inside the `.geo` text editor now shows the same block preview tooltip available in the side lists.
- Direct text edits can be re-read and normalized with `Refresh`.

## Native gview integration

- Native `gview2d` and `gview3d` stay inside the Geometry tab.
- Startup now stages the current geometry automatically.
- Blank native launches are retried automatically up to the configured limit.
- Retry diagnostics stay in background logs instead of forcing the side log open.
- `Open .rep` now targets the session-local `geometry.rep`.

## Surface and body authoring

- Unified plane editor with always-available `OMEGA`, `THETA`, and `PHI`.
- Batch add for multiple surfaces of the same type.
- BODY definitions can include linked BODY rows in the structured editor.
- BODY add flow now stays open for repeated creation until `Cancel` or `Esc`.

## Project and safety improvements

- Project-local native gview sync for older projects.
- Single-instance safeguard for `penelope_studio`.
- Geometry recovery/snapshot protection improved around save/reopen flows.
