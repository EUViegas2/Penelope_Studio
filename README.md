# PENELOPE Simulation Studio

Desktop editor/viewer for PENELOPE geometry (`.geo`) and simulation input (`.in`) files.

Current active runtime file: `penelope_studio_v9_split_runs_patch_v2.py`  
Current no-console launcher: `Start_Penelope_Studio_V9_NoConsole.pyw`  
Effective in-app state/version: `V9`

This root is being normalized as the pre-V10 working runtime. Internal settings,
mutex, and temp roots still intentionally use the stable `V9` identity so user
settings and single-instance protection continue to carry across patches.

Stable fallback app file: `old versions/penelope_studio_v8.py`

## Fortran Native GView Workspace

- Project-owned native `gview` builds now belong under `fortran/`.
- Put adapted PENELOPE Fortran sources in:
- `fortran/src/gview2d/`
- `fortran/src/gview3d/`
- Build them with `fortran/build_gviews.ps1`.
- The Studio now prefers `fortran/bin/gview2d.exe` and `fortran/bin/gview3d.exe` automatically when they exist, while still allowing manual override in Settings.

## Current State

### V1: `penelope_studio.py`

- Original Studio version.
- Direct code editing with line numbers.
- Internal 2D and 3D renders available.

### V2: `penelope_studio_v2.py`

- Previous active development version.
- Kept as the stable baseline before the V3 rename.
- Contains the block workflow, high-level BODY/MODULE editing, render tools, and formatting fixes.

### V3: `penelope_studio_v3.py` (geometry checkpoint)

- Structured block workflow with three stacked sections:
- `Body/Module Blocks` (top)
- `Geometry Blocks` (middle)
- code editor (bottom)
- Toolbar actions: `NEW`, `OPEN`, `SAVE`, `SEP`, `END`, `ADD`.
- `NEW` template now starts with:
- `Title`
- separator (`000...`)
- `END ...`
- `ADD` supports structured creation of surfaces, bodies, and modules.
- `ADD -> Surface` includes all supported quadric options plus:
- `surface_plane` (single plane keyword)
- `surface_plane_xyz` (`AX/AY/AZ/A0` form, linear plane)
- High-level BODY/MODULE editing includes:
- label (capped to 20 chars)
- material
- center `X/Y/Z`
- linked non-plane surface params (`SCALE`/`SHIFT` when present)
- linked plane limits (`Min/Max`) when detectable
- type switch `BODY <-> MODULE` while preserving material and linked surfaces
- Center edits propagate to linked surfaces:
- linear planes update `A0`
- non-linear surfaces update/add `X/Y/Z-SHIFT`
- Surface ID edits now propagate to BODY/MODULE references (`SURFACE(...), SIDE POINTER=(...)`).
- Geometry and Body/Module block selection supports jump-to-code behavior.
- Internal 2D/3D rendering is integrated (Matplotlib/Numpy).
- `.geo` labels are sanitized to ASCII on save for compatibility.
- Autocomplete popup in the code editor is disabled to keep typing behavior like a normal notebook.
- Snippet expansion by keyword + `Tab` remains available.
- Latest V3 checkpoint before V4 Simulation work:
- `penelope_studio_v3_checkpoint_20260411_121447.py`

### V4: `penelope_studio_v4.py` (checkpoint)

- Created from the V3 geometry checkpoint on 2026-04-11.
- Active development now focuses on the Simulation (`.in`) tab.
- Simulation save continues using the same robust text encoding path as `.geo`/`.in` file handling (`_encode_text_bytes`) with CRLF normalization.
- Geometry and Simulation tabs include `Save` and `Save As...`; `Save As...` prompts for the target filename and then updates the active file path.
- New `.in` projects now use the full PENELOPE section template requested for source, material, geometry, interaction forcing, emerging particles, detectors, and job properties.
- Source quick edit is now a combined `Add Particle` / `Edit Particle` dialog:
- writes `SKPAR`, `SENERG`, `SPOSIT`, and `SCONE` into the Source definition section.
- when editing, pre-fills existing `SKPAR`, `SENERG`/`SPECTR`, `SPOSIT`, and `SCONE` values instead of resetting to zero/default values.
- `SENERG` has `keV` / `MeV` unit choice that writes `e3` / `e6`.
- `SENERG` and `SPECTR` are mutually exclusive rows in the Source dialog.
- existing `SPECTR` rows are preserved if the dialog remains in SPECTR mode and no replacement spectrum file is selected.
- `SPECTR` opens a file picker; it reads energy values from column 1, skips near-zero rows, assigns equal probability to each remaining row, and appends a final `SPECTR` row with probability `-1`.
- `SCONE` fields are labelled `theta`, `phi`, and `alpha`, with a Help button showing `scone_angles_help.png`.
- Material add dialog now:
- shows one fixed internal-ID row per `.mat` file found in the current `.in` folder.
- each row has an editable `.mat` dropdown, an `Add` checkbox to insert that material, and a separate `Edit` checkbox that reveals `EABS`/`MSIMPA` parameters.
- rows added without `Edit` use default `MSIMPA`; edited rows write the custom parameter values.
- Add/Edit material dialogs include compact `Order` fields so material entries can be written in a custom order.
- `Edit Materials` reviews existing `MFNAME`/`MSIMPA` pairs, supports filename edits, optional `MSIMPA` edits, custom ordering, and removing material entries in one dialog.
- Geometry quick edit now:
- offers `.geo` files from the same folder as the current `.in`.
- replaces only the existing `GEOMFN` line when geometry keywords are already present.
- creates the geometry block with `GEOMFN`, `DSMAX`, and default `EABS` only when none of the geometry keywords are present.
- `ADD IMPDET` adds an impact detector block:
- reads BODY IDs/labels from the currently selected `GEOMFN` `.geo` file.
- creates the Impact detectors section if it is missing.
- inserts `IMPDET` and `IDBODY` before that section's ending dot.
- Impact Detectors checkbox turns the section on/off quickly; turning it on creates the first detector for body 1 by default, and turning it off removes all impact-detector sections and `IMPDET`/`IDBODY` blocks.
- Interaction Forcing checkbox turns the default `IFORCE` section on/off and reflects existing `IFORCE` lines when a file is opened.
- Emerging Particles checkbox turns the `NBE`/`NBANGL` section on/off and reflects existing `NBE`/`NBANGL` lines when a file is opened.
- uses current `SENERG` for electron sources (`SKPAR 1`) and keeps existing `IMPDET` energy/bin values synchronized when source energy changes through dialogs or manual edits.
- Job Properties checkbox adds/removes the `RESUME`/`DUMPTO`/`DUMPP` section immediately before `NSIMSH`.
- `Run Simulation` now starts each `.in` as a separate background `QProcess` run and keeps a Running simulations list with filename, `NSIMSH`, status, and latest command-line output. Up to 6 simulations can run at once; the button disables at the limit and clicking beyond the limit warns `max threads running`. `Kill` stops only the selected run; `Kill All` stops every active run.
- Running simulation rows include compact `IN`, `N` (`NSIMSH`), `GEO` (`GEOMFN`), `SPOSIT` (`X/Y/Z`), `SCONE` (`theta/phi/alpha`), status, and latest output labels. The run controls sit beside the list to avoid crushing the list at narrower window sizes. Rows are removed automatically when the latest output line is exactly `*** END ***`.
- Simulation runs use a dedicated run folder: by default it is the folder where the `.in` was opened/saved-as from; changing the workspace root does not change it; creating a workspace switches it to the new case folder. The `.in` is fed through stdin, equivalent to `penmain < current_file.in`, so relative geometry/material/dump/output paths resolve in that run folder.
- Before launching a simulation, any existing top-level `*.dat` outputs in the run folder are moved into `previous run`; the active `.in`, `.geo`, and `.mat` files are copied there for traceability. If PENELOPE reports `The dump file is empty or corrupted`, top-level `*.dmp` files are moved into `dmps` and the same workspace is retried once.
- The run command is launched through `cmd.exe /C` so the command form remains exactly `penmain < current_file.in`.
- Opening an `.in` sets the current root to the opened file folder, updates the Root label, and logs `[SIM] Current root: ...`.
- Workspace tools in the Simulation tab let the user choose a root folder, then create a case folder named from the current `.in` and `GEOMFN` `.geo` stems with duplicate tokens removed. The new case folder receives the root `template` folder contents, an active copy of the current editor `.in`, the selected `.geo`, and all `.mat` files from the root. After creation, the editor is linked to the workspace `.in` copy.
- Workspace creation now protects PENELOPE's `GEOMFN` 20-character filename limit by copying long `.geo` names to a short alias inside the case folder and rewriting `GEOMFN` in the workspace `.in`.
- Recreating an existing workspace skips already-present template files to avoid Windows file-lock errors from executables currently in use; the active `.in` and selected `.geo` are still refreshed.
- Simulation matrix `.geo` batch files can be generated from `simulation_matrix_with_source_parameters.xlsx`; the 2026-04-11 batch was written to `C:\Users\viega\Desktop\MEBiSEL\FMIII\Relatório02-` with wall planes centered on `x=0` and PENELOPE-safe filenames of 20 characters or less. Vacuum is omitted from filenames, e.g. `120k_1m_10cm.geo`.

- Latest V4 checkpoint before V5 no-code Simulation Blocks work:
- `penelope_studio_v4_checkpoint_20260412_132706.py`

### V5: `penelope_studio_v5.py` (active)

- Created from V4 on 2026-04-12.
- Active development focuses on making the Simulation tab work more like a no-code IDE over the `.in` file.
- Adds a `Simulation Blocks` tree above the quick-edit buttons.
- The `Simulation Blocks` section is hidden at startup and appears only after a new `.in` is created or an existing `.in` is opened.
- The tree follows the hierarchy defined in `table.xlsx`, parsing the current `.in` into single-column linked blocks for `Title`, `>>>>>>>> Source definition.`, Materials, Geometry, Interaction forcing, Emerging particles, Impact detectors, Job properties, `NSIMSH`, and `TIME`.
- Source blocks now keep separate sub-attribute levels: `SKPAR -> Value`, `SENERG/SPECTR -> SENERG value` or `SPECTR file path`, `SPOSIT -> Value`, and `SCONE -> Value`.
- Material blocks show current material order, `.mat` file, and `MSIMPA` values.
- Geometry blocks show `GEOMFN`; Run controls show Interaction forcing, Emerging particles, Impact detectors, Job properties, `NSIMSH`, and `TIME`.
- Double-clicking a block opens the existing structured editor for the selected linked data.
- Right-clicking a parent block opens add/edit options for that section, e.g. Source can add/edit particle type, energy, position, and cone.
- Right-clicking an attribute block opens edit/delete options specific to that attribute.
- Source attributes now have separate value-only editors for `SKPAR`, `SENERG`, `SPECTR`, `SPOSIT`, and `SCONE`.
- `SENERG/SPECTR` is now a mode selector with two choices; the active mode controls whether the next block level is `SENERG` with its value or `SPECTR` with its file path/`None`.
- Optional sections that are inactive are hidden from the block tree instead of appearing as `inactive`.
- `NSIMSH` and `TIME` blocks display their full file line format instead of only a parsed/default value.

### V6: `penelope_studio_v6.py` (stable fallback)

- Created from V5 on 2026-04-12 without replacing V5 as the main working branch.
- Adds a third tab: `Analysis (.dat)`.
- Analysis is workspace-based: select the folder where a simulation ran instead of opening one `.dat` file at a time.
- The tab auto-detects `penmain.dat`, `penmain-res.dat`, `energy-*.dat`, `polar-angle-*.dat`, `spc-impdet-*.dat`, and the workspace `.geo`.
- `penmain-res.dat` is parsed into run-summary text and an average deposited-energy table.
- Deposited-energy `Body N` rows are mapped to BODY/MODULE labels from the workspace `.geo` by order of appearance, with explicit BODY/MODULE id as fallback. This matters because PENELOPE output can report `Body 1` for the first BODY block even when the `.geo` block is named `BODY(2)`.
- Each deposited-energy body row is followed by a smaller geometry row. The geometry row shows axis-plane bounds/approximate center when those can be inferred from linked surfaces, otherwise it falls back to linked surface IDs and a conservative note.
- Analysis can link/create a dose `.xlsx` workbook with headers `Case`, `Distance (m)`, `Wall Thickness (cm)`, `Body`, `Component`, `Edep (eV)`, `dE (eV)`, `Error (%)`, `Mass (kg)`, `Dose (Gy)`, and `dDose (Gy)`.
- The `Dose XLSX...` button can select an existing workbook or name a new one; once selected, that workbook stays fixed while switching analysis workspaces until another workbook is chosen.
- `Append Dosage Rows` appends one row per body plus a `Total Dosage` row for the current workspace. It converts eV to joules with `1.602176634e-19` and calculates `Dose = Edep_J / Mass_kg`, with `dDose` from the same relative uncertainty.
- `Multi Append` selects a root folder containing many simulation workspace folders, creates/updates `auto_Dose.xlsx` in that root, and refreshes each case by deleting existing rows for that case before appending the newly parsed body rows plus `Total Dosage`.
- Analysis root controls are split into a root row and a workspace row. The workspace row has a dropdown of candidate completed workspaces under the root; candidates must contain `penmain-res.dat`, a `.geo`, and a `.mat`.
- Mass is computed from workspace outputs: material density comes from `material.dat`/`.mat`, body material and surfaces come from `.geo`, and body volume is estimated by deterministic geometry sampling. Dose no longer depends on mass values pre-existing in the workbook. If a result body cannot be matched to a `.geo` body, or volume/density cannot be inferred, mass/dose remain blank.
- V6 launcher: `Start_Penelope_Studio_V6.cmd`.
- Material blocks can be dragged within the Materials parent to reorder `MFNAME`/`MSIMPA` entries in the `.in` file.
- Dragging a material block out of the Simulation Blocks tree unlinks/deletes that material pair from the file.
- Simulation tab has a `Batch Scripts` section linked to the existing Workspace `Root`. Batch actions ignore `.in` files directly in the root and only use child workspace folders that contain `.in`, `.geo`, and `.mat` files. `Batch NSIMSH` updates/inserts `NSIMSH` in those workspace `.in` files, and `Run Batch` launches `penmain < filename.in` in each workspace while reusing the existing simulation log/list UI. The `Has dmp` checkbox filters both batch actions to only workspaces that already contain a `.dmp` file. Batch thread count is selectable from 2 to 6, and `Run Selected` opens a checked workspace list so only chosen workspaces are queued.
- Batch runs show a progress summary (`finished/running/queued/failed`) above the running list. Finished items remain visible in the list, with status-first text and color hints, so long batches are easier to audit.
- Simulation launching now guards against duplicate active runs in the same workspace folder, preventing two `penmain` processes from writing the same `dump.dmp`, `penmain.dat`, or `penmain-res.dat` at the same time.
- Simulation tab now has the pre-run `Risk Assessment` button. It uses `NSIMSH` and `TIME` from the current `.in` as baseline and enforces target error 5%.
- Analysis tab no longer has a `Risk Assessment` button.
- Dose `.xlsx` export now applies conditional formatting on `Error (%)`, sets row `Quality` labels (`Accepted`/`Uncertain`/`Unreliable`), adds auto-filter + frozen header, and keeps these rules when appending to existing workbooks.
- Dose workbook columns include `N ref`, `Time ref (s)`, `Target Err (%)`, `NSIMSH @5%`, `Time @5% (s)`, and `Quality`. The old `Err @3e6/@1e7/@3e7/@1e8` columns were removed.
- Simulation `Set Geometry File` now uses a persistent `.geo` list folder. By default the list comes from the current `.in` folder; `Browse...` selects a folder, refreshes the dropdown with that folder's `.geo` files, and keeps that folder for future geometry popups until another folder is selected.
- Simulation material dialogs now use the same catalog pattern for `.mat` files. By default material lists come from the current `.in` folder; `Browse...` selects a material folder, refreshes/reopens the material list from that folder, and keeps it for future material popups. Workspace creation copies `.mat` files from the selected material folder as well as the workspace root.
- Closing the Studio now checks both the Geometry and Simulation editors for unsaved changes. If either active `.geo` or `.in` file is dirty, the user is prompted to `Save`, `Save As...`, `Discard`, or `Cancel` before the application closes.
- Saving an existing `.in` now has a resume-safety guard. If the new file differs from the previous saved file in anything other than `NSIMSH`, `TIME`, or `DUMPP`, V6 creates `input change backups/<timestamp>` inside the workspace before overwriting. It copies the existing workspace contents there and moves top-level `.dat`/`.dmp` files out of the active workspace so a changed source/geometry/material setup does not accidentally resume from an old dump.
- After `Kill All` or after any batch run completes, the Running simulations list is marked for clearing. Existing rows stay visible for review, then are erased automatically when the next single run or batch run starts.

### V9 state: `penelope_studio_v9_split_runs_patch_v2.py` (active)

- Created from the V8 working version as the current active version.
- The current runnable root patch is `penelope_studio_v9_split_runs_patch_v2.py`.
- The no-console launcher is `Start_Penelope_Studio_V9_NoConsole.pyw`, which now targets the patch-v2 runtime.
- Geometry tab:
- adds grouped geometry block support so selected bodies/surfaces/modules can be organized into named expandable groups.
- adds complex body/module creation groundwork, including BOX creation from plane limits and module linked-body selection.
- adds the `Create Material` bridge window for PENELOPE `material.exe`: step-by-step mode keeps the interactive console, while Easy mode reads `pdfiles/pdcompos.p08`, lets the user select a material by ID/name, runs `material.exe` from its required `pendbase` folder, and moves the generated `.mat` to the chosen output folder.
- includes local ANIB extraction notes for head phantom planning at `reports/generated_scans/ANIB_head_model_notes_20260422.md`.
- improves workspace/body/module ID handling, including Auto ID fixes so main SURFACE/BODY/MODULE declaration blocks and internal references stay synchronized.
- Simulation tab:
- supports queueing simulation runs from multiple roots and keeps running rows more informative.
- running rows include source position/cone metadata and can open the linked `.in` for checking.
- batch progress summaries track finished/skipped/completed/failed/running/queued states.
- project setup now includes:
- project description
- case-folder naming based on predefined selected fields with a live example
- optional checkboxes for using the local project `geometry/` and `materials/` folders as active file sources
- project file management now includes import/export support through Project Explorer and File menu actions.
- projects now create and maintain:
- `cases/`
- `geometry/`
- `materials/`
- `instructions/`
- `analysis/`
- Simulation `File Sources` no longer auto-switch to project-local folders unless the project explicitly opts in.
- Create Case naming is now generalized:
- inside projects, case folder names follow the selected project case-name fields
- outside projects, the default is `particle_type_energy_type_geo_file_nsimsh`
- executable paths remain global Settings values; project-level executable override UI was removed.
- keeps safeguards for save prompts, dump handling, previous-run archiving, and no-console launch via `Start_Penelope_Studio_V9_NoConsole.pyw`.
- Analysis tab:
- supports recursive/non-recursive multi-append workflows over grouped report folders.
- dose export now includes explicit energy conversion columns `Edep (J)` and `dE (J)` in addition to eV, so `Dose (Gy) = Edep (J) / Mass (kg)` is auditable.
- distance parsing understands the current workspace naming convention (`pd...`, `bd...`, `wt...`) and fills particle distance, source-origin/wall distance, source-body distance, and wall thickness.
- report curation work completed on 2026-04-20:
- created report-facing grouped folders under `C:\Users\viega\Desktop\MEBiSEL\FMIII\Simulações Report 02`, including LINAC/x-ray comparisons, rod-spacing pairs, air/no-air pairs, and LINAC `alpha=2.86` pair sets.
- created the zip-ready package `Report_02_Zip_Ready_20260420_045627` with old dumps/executables/backups excluded.
- Previous V8 code is archived in `old versions/penelope_studio_v8.py`.

## Local Folder Organization

- Active Studio runtime files stay at the project root, with `penelope_studio_v9_split_runs_patch_v2.py` as the current launcher target.
- Checkpoints are stored in `checkpoints/studio_versions/`.
- Generated scan/audit CSV/XLSX/TXT files are stored in `reports/generated_scans/`.
- Cleanup manifests are stored in `reports/`.
- Bulk geometry-edit backup folders are stored in `backups/geometry_bulk_edits/`.
- Temporary Codex test folders are stored in `scratch/codex_tests/`.

### Simulation Tab

- Full `.in` editor + syntax highlighting.
- V5 block-based no-code scaffold plus V4 section-aware quick-edit commands for source, materials, geometry, `NSIMSH`, and `TIME`.
- Run/Kill simulation process via configured `penmain`.

## Install

```powershell
cd "C:\Users\viega\Desktop\CodAI"
py -m pip install -r requirements.txt
```

## Run

Option 1:

```powershell
cd "C:\Users\viega\Desktop\CodAI"
py penelope_studio_v7.py
```

Option 2 (shortcut script):

```powershell
cd "C:\Users\viega\Desktop\CodAI"
pyw .\Start_Penelope_Studio_V7_NoConsole.pyw
```

Option 3 (create desktop shortcut once):

```powershell
cd "C:\Users\viega\Desktop\CodAI"
powershell -ExecutionPolicy Bypass -File .\Create_Desktop_Shortcut.ps1
```

Optional args:

```powershell
py penelope_studio_v7.py path\to\geometry.geo path\to\simulation.in
```

## Cross-PC Session Handoff

- Keep this folder synced to both PCs (OneDrive already fits this workflow).
- Use the same startup script on both machines: `Start_Penelope_Studio_V7_NoConsole.pyw`.
- On the second PC, run dependency install once:
- `py -m pip install -r requirements.txt`
- Continue from latest active file:
- `penelope_studio_v7.py`
- Optional restore points:
- `checkpoints/studio_versions/penelope_studio_v*_checkpoint_*.py`

## Continuation Proposal (Next Session)

- Add an optional "dimension mode" in BODY high-level edit:
- show axis size as bounds (`Xmin/Xmax`, `Ymin/Ymax`, `Zmin/Zmax`)
- keep center and bounds synchronized both ways
- Add validation for surface ID conflicts before accepting edits:
- warn if target ID already exists
- offer auto-remap choice
- Add an explicit block-link inspector:
- list all bodies/modules that reference selected surface
- one-click jump between linked blocks
- Add undo/redo safety for structured edits:
- one action per dialog apply
- visible in status/console

## Repository Files

- `penelope_studio.py`: V1 legacy editor/viewer.
- `penelope_studio_v2.py`: V2 previous active development file.
- `penelope_studio_v3.py`: V3 geometry checkpoint file.
- `penelope_studio_v4.py`: V4 Simulation checkpoint file.
- `penelope_studio_v5.py`: V5 stable Simulation Blocks baseline.
- `penelope_studio_v6.py`: V6 active branch with Simulation + Analysis workflow.
- `Start_Penelope_Studio_V2.cmd`: V2 launcher shortcut script.
- `Start_Penelope_Studio_V3.cmd`: V3 launcher shortcut script.
- `Start_Penelope_Studio_V4.cmd`: V4 launcher shortcut script.
- `Start_Penelope_Studio_V5.cmd`: V5 launcher shortcut script.
- `Start_Penelope_Studio_V6.cmd`: V6 launcher shortcut script.
- `Create_Desktop_Shortcut.ps1`: creates a desktop `.lnk` shortcut to the launcher.
- `phantom_studio.py`: separate/legacy tool.
- `penelope_studio_v2_checkpoint_*.py`: V2 manual checkpoints.
- `penelope_studio_v3_checkpoint_*.py`: V3 manual checkpoints.
- `penelope_studio_v4_checkpoint_*.py`: V4 manual checkpoints.
- `penelope_studio_v6_checkpoint_*.py`: V6 manual checkpoints.

## Latest Checkpoint

- `penelope_studio_v6_checkpoint_20260413_175948.py`
