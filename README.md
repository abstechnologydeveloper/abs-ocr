# AbS OpenDataLoader OCR

Source and Terraform deployment for the AbS OCR service at `ocr.abstechconnect.com`.

This project configures the current VPS. It does not create a new cloud VM.

## What It Deploys

- Deployable OCR source from `service/`
- Python venv under `/opt/abs-ocr/venv`
- `opendataloader-pdf[hybrid]==2.4.3`
- CPU-only `torch`/`torchvision` wheels, to avoid CUDA package bloat on the VPS
- AbS launcher: `abs-ocr-server`
- systemd service: `opendataloader-hybrid.service`
- nginx reverse proxy for `ocr.abstechconnect.com`
- HTTPS certificate through Certbot

## Project Layout

- `service/`: local source code that is uploaded to production
- `terraform/`: VPS deployment automation
- `systemd/`: service template
- `nginx/`: reverse proxy template
- `.github/workflows/deploy.yml`: CI deployment

## Requirements

- DNS `ocr.abstechconnect.com` points to the VPS.
- SSH user can run `sudo`.
- Terraform installed locally.

## Deploy

### GitHub Actions Deployment

This repository deploys from `.github/workflows/deploy.yml` on push to `main`.
It follows the same shape as the backend deploy: self-hosted runner, full
checkout, service update, health validation with retries.
Local code changes should be committed and pushed to `main`; CI will copy the
current `service/` folder to the VPS and restart production.

Create these GitHub repository secrets:

- `OCR_HOST`: `155.117.43.107`
- `OCR_SSH_USER`: `administrator`
- `OCR_SSH_PRIVATE_KEY`: preferred SSH key for the VPS. If omitted, the workflow falls back to `SSH_PRIVATE_KEY`.
- `OCR_SSH_PASSWORD`: optional SSH password fallback
- `OCR_SUDO_PASSWORD`: sudo password

Optional repository variables:

- `OCR_DOMAIN`: `ocr.abstechconnect.com`
- `LETSENCRYPT_EMAIL`: `admin@abstechconnect.com`
- `OCR_FORCE_OCR`: `false` by default. Set `true` for all-scanned PDF workloads.
- `OCR_LANG`: `en` by default. Use comma-separated EasyOCR codes like `ko,en`, `fr,en`, or `ar,en`.
- `OCR_ENRICH_FORMULA`: `true` by default for math/STEM extraction.
- `OCR_ENRICH_PICTURE_DESCRIPTION`: `false` by default because it is CPU-heavy.

Then push to `main`.

### Local Deployment

Do not commit secrets. Pass them as environment variables:

```bash
cd /Users/apple/Desktop/abs-opendataloader-ocr/terraform
terraform init

export TF_VAR_ssh_password='REPLACE_WITH_SSH_PASSWORD'
export TF_VAR_sudo_password='REPLACE_WITH_SUDO_PASSWORD'

terraform apply
```

If using SSH key auth locally:

```bash
export TF_VAR_ssh_private_key="$(cat ~/.ssh/id_rsa)"
export TF_VAR_sudo_password='REPLACE_WITH_SUDO_PASSWORD'
```

If SSH and sudo password are the same, you can set both password variables to the same value.

## Verify

```bash
curl -i https://ocr.abstechconnect.com/health
curl -i http://127.0.0.1:5002/health
```

On the VPS:

```bash
systemctl status opendataloader-hybrid.service --no-pager -l
journalctl -u opendataloader-hybrid.service -n 100 --no-pager
```

## Current Production Status

As of this setup, the existing VPS service has been restored manually:

- `opendataloader-hybrid.service`: active
- `ocr.abstechconnect.com`: HTTPS enabled
- health endpoint: `https://ocr.abstechconnect.com/health`

Terraform in this folder is the reproducible deployment path for later redeploys.

## Upgrade OpenDataLoader

Update `service/requirements.txt`, commit, and push to `main`.
GitHub Actions will reinstall the pinned version and restart the service.

Keep the CPU PyTorch pins unless the VPS gets a real CUDA GPU. Without those
pins, the Linux dependency resolver can pull CUDA wheels and make the OCR
environment several GB larger with no benefit on this CPU machine.

## OCR Modes

Default production mode is fast hybrid extraction:

```bash
opendataloader-pdf-hybrid --port 5002
```

For image-only scanned PDFs, deploy with:

```text
OCR_FORCE_OCR=true
```

For non-English OCR, deploy with:

```text
OCR_LANG=ko,en
```

Formula extraction is enabled by default:

```text
OCR_ENRICH_FORMULA=true
```

## Notes

- Default mode is hybrid auto-detect, not forced OCR. This is faster for text PDFs.
- Set `OCR_FORCE_OCR=true` only when every page should go through OCR. That is slower and should only be used for scanned materials.
- Backend should call this service from a queue worker, not inside the normal request path.
