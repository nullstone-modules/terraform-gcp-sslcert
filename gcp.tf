resource "google_project_service" "cert-manager" {
  service                    = "certificatemanager.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}
