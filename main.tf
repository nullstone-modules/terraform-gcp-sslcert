data "google_dns_managed_zone" "domains" {
  for_each = var.subdomains

  name = each.value
}

locals {
  domain_names = {for key, _ in var.subdomains : key => trimsuffix(data.google_dns_managed_zone.domains[key].dns_name, ".")}
}

resource "google_certificate_manager_dns_authorization" "this" {
  for_each = var.subdomains

  name        = replace(each.key, ".", "-")
  description = "Managed by Nullstone"
  domain      = local.domain_names[each.key]
}

locals {
  auth_records = { for key, _ in var.subdomains : key => google_certificate_manager_dns_authorization.this[key].dns_resource_record.0 }
}

resource "google_dns_record_set" "authorization_records" {
  for_each = var.subdomains

  managed_zone = each.value
  name         = local.auth_records[each.key].name
  type         = local.auth_records[each.key].type
  rrdatas      = [local.auth_records[each.key].data]
  ttl          = 300
}

resource "google_certificate_manager_certificate" "this" {
  depends_on = [google_dns_record_set.authorization_records]

  name        = var.cert_name
  description = "Managed by Nullstone"
  scope       = "EDGE_CACHE"

  managed {
    domains            = [ for da in google_certificate_manager_dns_authorization.this : da.domain ]
    dns_authorizations = [ for da in google_certificate_manager_dns_authorization.this : da.id ]
  }
}
