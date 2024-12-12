variable "enabled" {
  type        = bool
  default     = true
  description = "This enables/disables creating the SSL certificate. We cannot use module count because we have aliased providers."
}

variable "name" {
  type        = string
  description = <<EOF
A user-defined name of the certificate.
Certificate names must be unique.
The name must be 1-64 characters long, and match the regular expression [a-zA-Z][a-zA-Z0-9_-]* which means the first character must be a letter, and all following characters must be a dash, underscore, letter or digit.
EOF
}

variable "subdomains" {
  type = map(string)

  description = <<EOF
A list of subdomains represented as a map to register on the SSL certificate.
In each key/value pair, the key refers to the DNS name of the subdomain and the value refers to the GCP unique zone name of the domain.
If you want to use the dns_name from the domain zone, use `.` for the map key.
EOF
}

locals {
  subdomains = var.enabled ? var.subdomains : tomap({})
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "A map of labels to apply to certificate resources"
}

variable "scope" {
  type        = string
  default     = ""
  description = <<EOF
The scope of the certificate relies on how the certificate will be used.
- "": (default) For use with Load Balancing and Cloud CDN
- "ALL_REGIONS": For use with cross-region internal application load balancing
- "EDGE_CACHE": For use with media edge services
EOF

  validation {
    condition     = contains(["EDGE_CACHE", "ALL_REGIONS", ""], var.scope)
    error_message = <<EOF
scope must be one of "EDGE_CACHE", "ALL_REGIONS", or ""
EOF
  }
}