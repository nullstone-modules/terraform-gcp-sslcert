output "certificate_name" {
  value       = try(google_certificate_manager_certificate.this[0].name, "")
  description = "The name of the certificate in GCP."
}

output "certificate_id" {
  value       = try(google_certificate_manager_certificate.this[0].id, "")
  description = "The ID of the certificate in GCP. (Format: projects/{{project}}/locations/global/certificates/{{name}})"
}

output "certificate_map_id" {
  value       = try(google_certificate_manager_certificate_map.this[0].id, "")
  description = "The ID of the certificate map in GCP Certificate Manager. (Format: projects/{{project}}/locations/global/certificateMaps/{{name}})"
}
