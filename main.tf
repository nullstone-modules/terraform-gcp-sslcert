data "google_dns_managed_zone" "domains" {
  for_each = local.subdomains

  name = each.value
}

data "google_client_config" "this" {}

locals {
  domain_names = { for key, _ in local.subdomains : key => trimsuffix(data.google_dns_managed_zone.domains[key].dns_name, ".") }
}

resource "google_certificate_manager_dns_authorization" "this" {
  for_each = local.subdomains

  name        = replace(each.key, ".", "-")
  labels      = var.labels
  description = "${each.key}: Created by Nullstone"
  domain      = local.domain_names[each.key]

  depends_on = [google_project_service.cert-manager]
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
  count      = var.enabled ? 1 : 0

  name        = var.name
  labels      = var.labels
  description = "Created by Nullstone"
  scope       = var.scope == "" ? "DEFAULT" : var.scope

  managed {
    domains            = [for da in google_certificate_manager_dns_authorization.this : da.domain]
    dns_authorizations = [for da in google_certificate_manager_dns_authorization.this : da.id]
  }
}

resource "google_certificate_manager_certificate_map" "this" {
  count = var.enabled ? 1 : 0

  name        = var.name
  labels      = var.labels
  description = "${var.name}: Created by Nullstone"

  depends_on = [google_project_service.cert-manager]
}

resource "google_certificate_manager_certificate_map_entry" "this" {
  count = var.enabled ? 1 : 0

  name         = var.name
  labels       = var.labels
  description  = "${var.name}: Created by Nullstone"
  map          = google_certificate_manager_certificate_map.this[count.index].name
  certificates = [google_certificate_manager_certificate.this[count.index].id]
  matcher      = "PRIMARY"
}
