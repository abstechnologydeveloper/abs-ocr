output "ocr_http_health_url" {
  value = "http://${var.domain}/health"
}

output "ocr_https_health_url" {
  value = "https://${var.domain}/health"
}

output "systemd_service" {
  value = "opendataloader-hybrid.service"
}
