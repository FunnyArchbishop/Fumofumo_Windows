"""Delete files from dist/Fumofumo that Fumofumo never uses, to shrink the package.

Called at the end of build_exe.bat. Everything removed here is a Qt module or
resource this app does not touch:

  opengl32sw.dll   Qt's software OpenGL fallback (19.7 MB). We render with
                   moderngl + a real GL context, and Qt widgets run on raster.
  translations/    Qt's own UI translations. The UI text is hardcoded Chinese and
                   Windows native dialogs are used, so these are dead weight.
  Qt6Quick/Qml*    QML engine -- this app is plain widgets.
  Qt6Pdf/Qt6Network/Qt6Sql/Qt6Test/...  unused modules.
  plugins/*        only the platform + style plugins are kept.

Run with --dry-run to see what would be removed.
"""
import sys
from pathlib import Path

DIST = Path(__file__).resolve().parent / "dist" / "Fumofumo"
INTERNAL = DIST / "_internal"
PS = INTERNAL / "PySide6"

# exact files (relative to _internal/PySide6)
DROP_FILES = [
    "opengl32sw.dll",
    "Qt6Quick.dll", "Qt6Qml.dll", "Qt6QmlModels.dll", "Qt6QmlWorkerScript.dll",
    "Qt6QuickControls2.dll", "Qt6QuickTemplates2.dll", "Qt6QuickWidgets.dll",
    "Qt6Pdf.dll", "Qt6PdfWidgets.dll", "Qt6Network.dll", "Qt6Sql.dll",
    "Qt6Test.dll", "Qt6Concurrent.dll", "Qt6PrintSupport.dll", "Qt6Svg.dll",
    "Qt6Designer.dll", "Qt6UiTools.dll", "Qt6OpenGL.dll", "Qt6OpenGLWidgets.dll",
    "QtNetwork.pyd", "QtQml.pyd", "QtQuick.pyd", "QtSql.pyd", "QtTest.pyd",
    "QtConcurrent.pyd", "QtPdf.pyd", "QtPdfWidgets.pyd", "QtSvg.pyd",
    "QtOpenGL.pyd", "QtOpenGLWidgets.pyd", "QtDesigner.pyd", "QtUiTools.pyd",
]

# whole directories (relative to _internal/PySide6)
DROP_DIRS = ["translations", "qml"]

# plugin subdirectories that are not needed
DROP_PLUGIN_DIRS = ["networkinformation", "tls", "qmltooling", "generic", "iconengines"]

# must survive, otherwise the app cannot start
KEEP = [
    PS / "Qt6Core.dll",
    PS / "Qt6Gui.dll",
    PS / "Qt6Widgets.dll",
    PS / "QtCore.pyd",
    PS / "QtGui.pyd",
    PS / "QtWidgets.pyd",
    PS / "plugins" / "platforms" / "qwindows.dll",
]


def size_of(path):
    if path.is_file():
        return path.stat().st_size
    if path.is_dir():
        return sum(p.stat().st_size for p in path.rglob("*") if p.is_file())
    return 0


def main():
    dry = "--dry-run" in sys.argv
    if not DIST.is_dir():
        print(f"  ! dist not found: {DIST}")
        return 1

    missing = [p for p in KEEP if not p.exists()]
    if missing:
        print("  ! refusing to trim: required file missing:")
        for m in missing:
            print(f"      {m.relative_to(DIST)}")
        return 1

    before = size_of(DIST)
    removed = 0

    targets = [PS / name for name in DROP_FILES]
    targets += [PS / name for name in DROP_DIRS]
    targets += [PS / "plugins" / name for name in DROP_PLUGIN_DIRS]

    for path in targets:
        if not path.exists():
            continue
        n = size_of(path)
        if not dry:
            if path.is_dir():
                import shutil
                shutil.rmtree(path, ignore_errors=True)
            else:
                path.unlink(missing_ok=True)
        removed += n
        print(f"  - {path.relative_to(DIST)}  ({n / 1048576:.1f} MB)")

    after = size_of(DIST)
    print(f"  trim: {before / 1048576:.1f} MB -> {after / 1048576:.1f} MB "
          f"(-{removed / 1048576:.1f} MB){' [dry run]' if dry else ''}")

    if not dry:
        missing = [p for p in KEEP if not p.exists()]
        if missing:
            print("  ! something required disappeared, check manually")
            return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
