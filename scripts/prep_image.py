"""
Card-Scout Image Prep
Checks an image file's size. If it exceeds the Claude Code vision read limit (~220KB),
compresses it to a JPEG under that limit and returns the new path on stdout.
If the file is already small enough, returns the original path unchanged.

HEIC/HEIF files:
  - macOS: converted automatically via the built-in `sips` tool (no extra install)
  - Windows: sips is not available; user must convert to JPG first

Usage:
    python scripts/prep_image.py inbox/IMG_4412.heic

Output (stdout):
    inbox/IMG_4412_compressed.jpg    <- path to use for vision read
    OR
    inbox/IMG_4412.jpg               <- original, if already small enough

Exit codes:
    0 = success (path printed on stdout)
    1 = error (message printed on stdout prefixed with ERROR:)
"""

import sys
import os
import subprocess
import platform
from pathlib import Path

SIZE_LIMIT_BYTES = 220 * 1024  # 220KB — safe margin below the 256KB Read tool limit

HEIC_EXTENSIONS = {".heic", ".heif"}
PILLOW_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp", ".tiff", ".tif"}
SUPPORTED_EXTENSIONS = HEIC_EXTENSIONS | PILLOW_EXTENSIONS


def convert_heic_with_sips(src: Path) -> Path:
    """Convert HEIC to JPEG using macOS built-in sips. Returns path to new JPEG."""
    dst = src.parent / (src.stem + "_converted.jpg")
    result = subprocess.run(
        ["sips", "-s", "format", "jpeg", str(src), "--out", str(dst)],
        capture_output=True, text=True
    )
    if result.returncode != 0 or not dst.exists():
        print(f"ERROR: Could not convert HEIC file. sips error: {result.stderr.strip()}")
        sys.exit(1)
    return dst


def compress_with_pillow(src: Path, target_bytes: int) -> Path:
    """Compress image using Pillow. Returns path to compressed JPEG."""
    try:
        from PIL import Image
    except ImportError:
        print("ERROR: Pillow is not installed. Run: pip install Pillow  (or: py -m pip install Pillow on Windows)")
        sys.exit(1)

    dst = src.parent / (src.stem + "_compressed.jpg")

    try:
        img = Image.open(src)
    except Exception as e:
        print(f"ERROR: Cannot open image file '{src.name}': {e}")
        sys.exit(1)

    if img.mode in ("RGBA", "P", "LA"):
        img = img.convert("RGB")

    for quality in (85, 70, 55, 40, 25):
        img.save(dst, format="JPEG", quality=quality, optimize=True)
        if dst.stat().st_size <= target_bytes:
            return dst

    # Last resort: resize by 50%
    w, h = img.size
    img_small = img.resize((w // 2, h // 2), Image.LANCZOS)
    img_small.save(dst, format="JPEG", quality=40, optimize=True)
    if dst.stat().st_size <= target_bytes:
        return dst

    print(
        f"ERROR: Could not compress {src.name} below {target_bytes // 1024}KB. "
        f"Final size: {dst.stat().st_size // 1024}KB. "
        f"Try taking the photo in standard JPEG mode instead of HEIC."
    )
    sys.exit(1)


def main():
    if len(sys.argv) < 2:
        print("ERROR: Usage: python scripts/prep_image.py <image-path>")
        sys.exit(1)

    src = Path(sys.argv[1])

    if not src.exists():
        print(f"ERROR: File not found: {src}")
        sys.exit(1)

    ext = src.suffix.lower()
    if ext not in SUPPORTED_EXTENSIONS:
        print(
            f"ERROR: Unsupported file type '{src.suffix}'. "
            f"Supported formats: JPG, PNG, WEBP, HEIC, BMP, TIFF"
        )
        sys.exit(1)

    # Step 1: Convert HEIC to JPEG first (Pillow can't read HEIC natively)
    working = src
    if ext in HEIC_EXTENSIONS:
        if platform.system() == "Darwin":
            working = convert_heic_with_sips(src)
        else:
            print(
                f"ERROR: HEIC files are not supported on Windows directly. "
                f"Please open the photo in the Photos app or iPhone transfer tool, "
                f"export it as JPG, and drop that into the inbox/ folder instead."
            )
            sys.exit(1)

    # Step 2: If already small enough, return as-is
    if working.stat().st_size <= SIZE_LIMIT_BYTES:
        print(str(working))
        return

    # Step 3: Compress with Pillow
    result = compress_with_pillow(working, SIZE_LIMIT_BYTES)

    # Clean up intermediate HEIC→JPEG conversion file if we compressed further
    if working != src and working.exists() and working != result:
        working.unlink()

    print(str(result))


if __name__ == "__main__":
    main()
