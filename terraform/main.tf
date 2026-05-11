locals {
  sudo_password = coalesce(var.sudo_password, var.ssh_password)
  service_args = compact([
    "--host 127.0.0.1",
    "--port ${var.service_port}",
    "--device ${var.device}",
    "--log-level info",
    "--max-file-size ${var.max_file_size_mb}",
    var.force_ocr ? "--force-ocr" : "",
    var.ocr_lang != "" ? "--ocr-lang ${var.ocr_lang}" : "",
    var.enrich_formula ? "--enrich-formula" : "--no-enrich-formula",
    var.enrich_picture_description ? "--enrich-picture-description" : "--no-enrich-picture-description",
  ])
}

resource "null_resource" "opendataloader_ocr" {
  triggers = {
    service_template = filesha256("${path.module}/../systemd/opendataloader-hybrid.service.tftpl")
    nginx_template   = filesha256("${path.module}/../nginx/opendataloader-ocr.conf.tftpl")
    domain           = var.domain
    port             = tostring(var.service_port)
    force_ocr        = tostring(var.force_ocr)
    formula          = tostring(var.enrich_formula)
    picture          = tostring(var.enrich_picture_description)
    max_size         = tostring(var.max_file_size_mb)
  }

  connection {
    type     = "ssh"
    host     = var.host
    user     = var.ssh_user
    password = var.ssh_password
    timeout  = "2m"
  }

  provisioner "file" {
    content = templatefile("${path.module}/../systemd/opendataloader-hybrid.service.tftpl", {
      ssh_user     = var.ssh_user
      service_args = join(" ", local.service_args)
    })
    destination = "/tmp/opendataloader-hybrid.service"
  }

  provisioner "file" {
    content = templatefile("${path.module}/../nginx/opendataloader-ocr.conf.tftpl", {
      domain               = var.domain
      service_port         = var.service_port
      client_max_body_size = var.nginx_client_max_body_size
    })
    destination = "/tmp/opendataloader-ocr.conf"
  }

  provisioner "remote-exec" {
    inline = concat([
      "set -euo pipefail",
      "SUDO_PASSWORD='${local.sudo_password}'",
      "sudo_cmd() { printf '%s\\n' \"$SUDO_PASSWORD\" | sudo -S -p '' \"$@\"; }",
      "sudo_cmd apt-get update",
      "sudo_cmd env DEBIAN_FRONTEND=noninteractive apt-get install -y python3-venv python3-pip openjdk-21-jre-headless nginx certbot python3-certbot-nginx curl",
      "sudo_cmd mkdir -p /opt/opendataloader",
      "sudo_cmd chown -R ${var.ssh_user}:${var.ssh_user} /opt/opendataloader",
      "python3 -m venv /opt/opendataloader/venv",
      "/opt/opendataloader/venv/bin/python -m pip install --upgrade pip wheel setuptools",
      "/opt/opendataloader/venv/bin/pip install --upgrade opendataloader-pdf",
      "sudo_cmd mv /tmp/opendataloader-hybrid.service /etc/systemd/system/opendataloader-hybrid.service",
      "sudo_cmd mv /tmp/opendataloader-ocr.conf /etc/nginx/sites-available/opendataloader-ocr",
      "sudo_cmd ln -sf /etc/nginx/sites-available/opendataloader-ocr /etc/nginx/sites-enabled/opendataloader-ocr",
      var.remove_legacy_nginx_config ? "sudo_cmd rm -f /etc/nginx/sites-enabled/opendataloader" : "true",
      "sudo_cmd nginx -t",
      "sudo_cmd systemctl daemon-reload",
      "sudo_cmd systemctl enable --now opendataloader-hybrid.service",
      "sleep 30",
      "curl -fsS http://127.0.0.1:${var.service_port}/health",
      "sudo_cmd systemctl reload nginx",
    ], var.enable_https ? [
      "sudo_cmd certbot --nginx -d ${var.domain} --non-interactive --agree-tos -m ${var.letsencrypt_email} --redirect || sudo_cmd certbot --nginx -d ${var.domain} --non-interactive --agree-tos --register-unsafely-without-email --redirect",
      "sudo_cmd nginx -t",
      "sudo_cmd systemctl reload nginx",
      "curl -fsS https://${var.domain}/health",
    ] : [
      "curl -fsS http://${var.domain}/health",
    ])
  }
}
