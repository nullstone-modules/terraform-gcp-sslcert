output "certificate_name" {
  value       = google_certificate_manager_certificate.this.name
  description = "The name of the certificate in GCP."
}

output "certificate_id" {
  value       = google_certificate_manager_certificate.this.id
  description = "The ID of the certificate in GCP. (Format: projects/{{project}}/locations/global/certificates/{{name}})"
}
