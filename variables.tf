variable "enabled" {
  type        = bool
  default     = true
  description = "This enables/disables creating the SSL certificate. We cannot use module count because we have aliased providers."
}

variable "cert_name" {
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
