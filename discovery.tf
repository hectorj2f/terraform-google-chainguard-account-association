// The service account to impersonate
resource "google_service_account" "chainguard_discovery" {
  project    = local.project_id
  account_id = "chainguard-discovery"
  depends_on = [google_project_service.iamcredentials-api]
}

// Allow the provider (mapped token) to impersonate this service account if
// the subject matches what we expect.
resource "google_service_account_iam_member" "allow_discovery_impersonation" {
  service_account_id = google_service_account.chainguard_discovery.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.chainguard_pool.name}/attribute.sub/discovery:${var.enforce_group_id}"
}

// Grant the service account permissions to access the resources it
// needs to fulfill its purpose.
resource "google_project_iam_member" "discovery_cluster_viewer" {
  project = local.project_id
  role    = "roles/container.clusterViewer"
  member  = "serviceAccount:${google_service_account.chainguard_discovery.email}"
}
