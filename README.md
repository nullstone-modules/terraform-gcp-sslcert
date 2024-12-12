# Google-managed SSL Certificate
Terraform module to create an SSL certificate using Google Certificate Manager.

This module performs automatic validation using DNS management.
As such, the certificate must be issued in the same GCP project where the DNS Zone is managed.

## Example

```terraform
resource "google_dns_managed_zone" "acme-com" {
  name     = "acme-com"
  dns_name = "acme.com"
}

module "cert" {
  source = "nullstone-modules/sslcert/gcp"

  enabled = true
  name    = "example-acme-com"
  scope   = ""

  // Produces a certificate with one subdomain `example.acme.com`
  // This certificate is authorized by adding DNS records to the acme.com DNS Zone
  subdomains = {
    "example.acme.com" = google_dns_managed_zone.acme-com.name
  }
}
```
