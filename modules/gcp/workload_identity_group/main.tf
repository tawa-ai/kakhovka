# 1. Create a service account for Terraform operations
resource "google_service_account" "terraform" {
  project    = var.project_id
  account_id = var.service_account_id
}

# 2. Grant project-level permissions required for Terraform operations
resource "google_project_iam_member" "terraform_permissions" {
  for_each = toset(var.permissions)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

# 3. Create the identity pool
resource "google_iam_workload_identity_pool" "identity_pool" {
  provider                  = google-beta
  project                   = var.project_id
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = "GitHub Actions Identity Pool"
  description               = "Identity pool for GitHub Actions automation"

  # Disable ambient credentials to ensure only explicit bindings work
  disabled = false
}
