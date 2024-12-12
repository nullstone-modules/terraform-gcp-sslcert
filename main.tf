data "google_dns_managed_zone" "domains" {
  for_each = local.subdomains

  name = each.value
}

data "google_client_config" "this" {}

locals {
  domain_names      = { for key, _ in local.subdomains : key => trimsuffix(data.google_dns_managed_zone.domains[key].dns_name, ".") }
  dns_auth_location = var.scope == "EDGE_CACHE" ? null : data.google_client_config.this.region
}

resource "google_certificate_manager_dns_authorization" "this" {
  for_each = local.subdomains

  name        = replace(each.key, ".", "-")
  labels      = var.labels
  description = "${each.key}: Created by Nullstone"
  domain      = local.domain_names[each.key]
  location    = local.dns_auth_location
}

locals {
  auth_records = { for key, _ in local.subdomains : key => google_certificate_manager_dns_authorization.this[key].dns_resource_record.0 }
}

resource "google_dns_record_set" "authorization_records" {
  for_each = local.subdomains

  managed_zone = each.value
  name         = local.auth_records[each.key].name
  type         = local.auth_records[each.key].type
  rrdatas      = [local.auth_records[each.key].data]
  ttl          = 300
}

resource "google_certificate_manager_certificate" "this" {
  depends_on = [google_dns_record_set.authorization_records]

  name        = var.name
  labels      = var.labels
  description = "Created by Nullstone"
  scope       = coalesce(var.scope, "DEFAULT")

  managed {
    domains            = [for da in google_certificate_manager_dns_authorization.this : da.domain]
    dns_authorizations = [for da in google_certificate_manager_dns_authorization.this : da.id]
  }
}

resource "google_certificate_manager_certificate_map" "this" {
  name        = var.name
  labels      = var.labels
  description = "${var.name}: Created by Nullstone"
}

resource "google_certificate_manager_certificate_map_entry" "this" {
  name         = var.name
  labels       = var.labels
  description  = "${var.name}: Created by Nullstone"
  map          = google_certificate_manager_certificate_map.this.name
  certificates = [google_certificate_manager_certificate.this.id]
  matcher      = "PRIMARY"
}
