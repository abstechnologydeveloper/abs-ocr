"""Launch the OpenDataLoader hybrid OCR server with AbS defaults."""

from __future__ import annotations

import os
import shutil
import sys


def _flag_enabled(name: str, default: bool = False) -> bool:
    raw = os.getenv(name)
    if raw is None:
        return default
    return raw.strip().lower() in {"1", "true", "yes", "on"}


def _default_args() -> list[str]:
    args = [
        "--host",
        os.getenv("ABS_OCR_HOST", "127.0.0.1"),
        "--port",
        os.getenv("ABS_OCR_PORT", "5002"),
        "--device",
        os.getenv("ABS_OCR_DEVICE", "cpu"),
        "--log-level",
        os.getenv("ABS_OCR_LOG_LEVEL", "info"),
        "--max-file-size",
        os.getenv("ABS_OCR_MAX_FILE_SIZE_MB", "80"),
    ]

    ocr_lang = os.getenv("ABS_OCR_LANG", "").strip()
    if ocr_lang:
        args.extend(["--ocr-lang", ocr_lang])

    if _flag_enabled("ABS_OCR_FORCE_OCR"):
        args.append("--force-ocr")

    args.append(
        "--enrich-formula"
        if _flag_enabled("ABS_OCR_ENRICH_FORMULA")
        else "--no-enrich-formula"
    )
    args.append(
        "--enrich-picture-description"
        if _flag_enabled("ABS_OCR_ENRICH_PICTURE_DESCRIPTION")
        else "--no-enrich-picture-description"
    )

    return args


def main() -> None:
    binary = shutil.which("opendataloader-pdf-hybrid")
    if binary is None:
        raise SystemExit(
            "opendataloader-pdf-hybrid was not found. "
            "Install service/requirements.txt first."
        )

    args = sys.argv[1:] or _default_args()
    os.execv(binary, [binary, *args])


if __name__ == "__main__":
    main()

