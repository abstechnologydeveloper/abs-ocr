# AbS OCR Service

This is the deployable source folder for the OCR runtime.

The actual OCR engine is OpenDataLoader, pinned in `requirements.txt`.
PyTorch is pinned to CPU-only wheels because the production VPS is CPU-only.
The `abs-ocr-server` launcher wraps the OpenDataLoader hybrid server so
production is deployed from this repository instead of being manually created
on the VPS.

## Runtime Modes

The launcher accepts normal OpenDataLoader CLI flags:

```bash
abs-ocr-server --host 127.0.0.1 --port 5002 --force-ocr --ocr-lang "ko,en" --enrich-formula
```

Without explicit CLI flags, it reads these environment variables:

- `ABS_OCR_FORCE_OCR`
- `ABS_OCR_LANG`
- `ABS_OCR_ENRICH_FORMULA`
- `ABS_OCR_ENRICH_PICTURE_DESCRIPTION`
- `ABS_OCR_MAX_FILE_SIZE_MB`
- `ABS_OCR_DEVICE`

## Local Run

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
pip install --no-deps -e .
abs-ocr-server --host 127.0.0.1 --port 5002 --device cpu --log-level info --enrich-formula
```

Health check:

```bash
curl -fsS http://127.0.0.1:5002/health
```
