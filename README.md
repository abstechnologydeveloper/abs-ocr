# AbS OpenDataLoader OCR Infra

Terraform deployment for the existing AbS OCR service at `ocr.abstechconnect.com`.

This project configures the current VPS. It does not create a new cloud VM.

## What It Deploys

- Python venv under `/opt/opendataloader`
- `opendataloader-pdf`
- systemd service: `opendataloader-hybrid.service`
- nginx reverse proxy for `ocr.abstechconnect.com`
- HTTPS certificate through Certbot

## Requirements

- DNS `ocr.abstechconnect.com` points to the VPS.
- SSH user can run `sudo`.
- Terraform installed locally.

## Deploy

### GitHub Actions Deployment

This repository deploys from `.github/workflows/deploy.yml` on push to `main`.

Create these GitHub repository secrets:

- `OCR_HOST`: `155.117.43.107`
- `OCR_SSH_USER`: `administrator`
- `OCR_SSH_PASSWORD`: SSH password
- `OCR_SUDO_PASSWORD`: sudo password

Optional repository variables:

- `OCR_DOMAIN`: `ocr.abstechconnect.com`
- `LETSENCRYPT_EMAIL`: `admin@abstechconnect.com`

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

If SSH and sudo password are the same, you can set both to the same value.

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

## Notes

- Default mode is hybrid auto-detect, not forced OCR. This is faster for text PDFs.
- Set `force_ocr = true` in Terraform if every page should go through OCR. That is slower and should only be used when needed.
- Backend should call this service from a queue worker, not inside the normal request path.
