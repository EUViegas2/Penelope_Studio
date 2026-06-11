#!/usr/bin/env python3
"""Legacy compatibility shim for older V9 entrypoints.

This file now forwards directly to the V10 runtime so existing shortcuts,
scripts, and habits continue to work after the release cutover.
"""

from __future__ import annotations

import runpy
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent
APP = ROOT / "penelope_studio_v10.py"


if __name__ == "__main__":
    sys.argv = [str(APP), *sys.argv[1:]]
    runpy.run_path(str(APP), run_name="__main__")
