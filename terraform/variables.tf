variable "host" {
  description = "Existing VPS public IP or hostname."
  type        = string
  default     = "155.117.43.107"
}

variable "ssh_user" {
  description = "SSH user for the VPS."
  type        = string
  default     = "administrator"
}

variable "ssh_password" {
  description = "SSH password. Pass with TF_VAR_ssh_password. Leave empty when using ssh_private_key."
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_private_key" {
  description = "SSH private key. Pass with TF_VAR_ssh_private_key. Preferred for GitHub CI."
  type        = string
  sensitive   = true
  default     = ""
}

variable "sudo_password" {
  description = "Sudo password. If omitted, ssh_password is used."
  type        = string
  sensitive   = true
  default     = ""
}

variable "domain" {
  description = "Public OCR domain."
  type        = string
  default     = "ocr.abstechconnect.com"
}

variable "letsencrypt_email" {
  description = "Let's Encrypt email."
  type        = string
  default     = "admin@abstechconnect.com"
}

variable "service_port" {
  description = "Local port for OpenDataLoader hybrid service."
  type        = number
  default     = 5002
}

variable "device" {
  description = "OpenDataLoader inference device."
  type        = string
  default     = "cpu"
}

variable "ocr_lang" {
  description = "Optional EasyOCR language list, for example en or en,fr."
  type        = string
  default     = "en"
}

variable "force_ocr" {
  description = "Force full-page OCR on all pages. Slower, useful for mostly scanned materials."
  type        = bool
  default     = false
}

variable "enrich_formula" {
  description = "Enable formula enrichment."
  type        = bool
  default     = false
}

variable "enrich_picture_description" {
  description = "Enable picture/chart descriptions. CPU-heavy."
  type        = bool
  default     = false
}

variable "max_file_size_mb" {
  description = "Maximum upload size accepted by OpenDataLoader. 0 means unlimited."
  type        = number
  default     = 80
}

variable "nginx_client_max_body_size" {
  description = "nginx upload limit."
  type        = string
  default     = "100m"
}

variable "allowed_client_cidrs" {
  description = "CIDR/IP allowlist for OCR conversion endpoints. Health remains public."
  type        = list(string)
  default = [
    "127.0.0.1",
    "155.117.43.107",
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}

variable "enable_https" {
  description = "Issue/install HTTPS certificate with Certbot."
  type        = bool
  default     = true
}

variable "remove_legacy_nginx_config" {
  description = "Remove old duplicate nginx site named opendataloader."
  type        = bool
  default     = true
}

variable "remove_legacy_install" {
  description = "Remove the old /opt/opendataloader install after the /opt/abs-ocr service is healthy."
  type        = bool
  default     = true
}
