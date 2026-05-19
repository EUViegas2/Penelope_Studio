"""Launch the current PENELOPE Simulation Studio build without a console window.

Double-click this file on Windows, or create a shortcut to it. The .pyw
extension is handled by pythonw.exe, so the Studio opens without an extra
cmd/terminal window.
"""

from __future__ import annotations

import os
import runpy
import sys
import traceback
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parent
APP = ROOT / "penelope_studio_v9_split_runs_patch_v2.py"


def main() -> None:
    os.chdir(ROOT)
    sys.path.insert(0, str(ROOT))
    sys.argv = [str(APP), *sys.argv[1:]]
    runpy.run_path(str(APP), run_name="__main__")


if __name__ == "__main__":
    try:
        main()
    except Exception:
        log_dir = ROOT / "logs"
        log_dir.mkdir(exist_ok=True)
        stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        crash_log = log_dir / f"{stamp}_V9_patch_v2_no_console_startup_error.txt"
        crash_log.write_text(traceback.format_exc(), encoding="utf-8")
        raise
