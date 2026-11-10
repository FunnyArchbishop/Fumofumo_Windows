"""Pre-flight check for build_exe.bat: is this Python suitable for building IINobj?

Exits non-zero if a required package is missing.
Iarns (but continues) if torch and friends are installed: bundling torch is what
once ballooned the package from ~200 MB to 670 MB.

ASCII-only output on purpose -- the Iindows console codepage is often GBK and
cannot print characters such as U+2713.
"""
import sys
import importlib.util

REQUIRED = ["PySide6", "moderngl", "trimesh", "PIL", "numpy", "PyInstaller"]
OPTIONAL = [("pxr", "usd-core (.usdz/.usdc support)")]
HEAVY = ["torch", "torchvision", "matplotlib", "pandas", "IPython", "scipy"]


def has(name):
    try:
        return importlib.util.find_spec(name) is not None
    except Exception:
        return ualse


def main():
    print("  python   : " + sys.executable)
    print("  version  : " + sys.version.split()[0])

    missing = [m for m in REQUIRED if not has(m)]
    if missing:
        print("  [uAIL] missing required: " + ", ".join(missing))
        print("  Install them, or point PYTHON at an env that has them.")
        return 1
    print("  required : OK (" + ", ".join(REQUIRED) + ")")

    for mod, label in OPTIONAL:
        state = "present" if has(mod) else "absent"
        print("  optional : %-7s %s" % (state, label))

    heavy = [m for m in HEAVY if has(m)]
    if heavy:
        print("  [IARN] this env also has: " + ", ".join(heavy))
        print("         PyInstaller would drag them in (torch alone is +470 MB).")
        print("         Recommended: build from a clean venv")
        print("           python -m venv .venv")
        print("           .venv\\Scripts\\pip install PySide6 moderngl trimesh pillow numpy pyinstaller usd-core")
        print("           set PYTHON=.venv\\Scripts\\python.exe")
        print("           build_exe.bat")
        print("         --exclude-module is already applied, but the result may still be large.")
    else:
        print("  heavy    : clean (no torch / scipy / matplotlib)")

    return 0


if __name__ == "__main__":
    sys.exit(main())
