#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-ocr.abstechconnect.com}"

echo "HTTP health"
curl -i "http://${DOMAIN}/health"

echo
echo "HTTPS health"
curl -i "https://${DOMAIN}/health"
