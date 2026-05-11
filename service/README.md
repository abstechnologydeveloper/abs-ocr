# AbS OCR Service

This is the deployable source folder for the OCR runtime.

The actual OCR engine is OpenDataLoader, pinned in `requirements.txt`.
The `abs-ocr-server` launcher wraps the OpenDataLoader hybrid server so
production is deployed from this repository instead of being manually created
on the VPS.

## Local Run

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
pip install --no-deps -e .
abs-ocr-server --host 127.0.0.1 --port 5002 --device cpu --log-level info
```

Health check:

```bash
curl -fsS http://127.0.0.1:5002/health
```

