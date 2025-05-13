/**
 * # GCP Bootstrap Module
 *
 * This module creates the foundational resources required to use Terraform with GCP:
 * - A GCS bucket for Terraform state storage
 * - A service account with appropriate permissions for Terraform operations
 * - IAM bindings for the service account
 */

# Local variables for resource naming and configuration
locals {
  # If terraform_state_bucket is provided, use it; otherwise, construct the name
  terraform_state_bucket = var.terraform_state_bucket != "" ? var.terraform_state_bucket : "${var.project_id}-terraform-state"

  # Full service account email
  service_account_email = google_service_account.terraform.email

  # Common labels to apply to all resources
  common_labels = merge(
    var.labels,
    {
      "managed-by" = "terraform"
      "module"     = "bootstrap"
    }
  )
}

# Create a GCS bucket for Terraform state storage
resource "google_storage_bucket" "terraform_state" {
  name          = local.terraform_state_bucket
  location      = var.location
  project       = var.project_id
  force_destroy = var.bucket_force_destroy

  # Enable versioning to keep history of state files
  versioning {
    enabled = true
  }

  # Enforce uniform bucket-level access
  uniform_bucket_level_access = var.uniform_bucket_level_access

  # Lifecycle rules for managing old state versions
  lifecycle_rule {
    condition {
      age = 30 # days
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }

  # Optional lifecycle rule to archive older versions
  lifecycle_rule {
    condition {
      num_newer_versions = 10
      age                = 90 # days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  labels = local.common_labels
}

# Create a service account for Terraform operations
resource "google_service_account" "terraform" {
  project      = var.project_id
  account_id   = var.service_account_name
  display_name = "Terraform Automation Service Account"
  description  = "Service account used for Terraform automation"
}

# Grant Storage Admin permissions on the Terraform state bucket
resource "google_storage_bucket_iam_member" "terraform_state_admin" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

# Grant project-level permissions required for Terraform operations
resource "google_project_iam_member" "terraform_permissions" {
  for_each = toset([
    "roles/compute.admin",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/storage.admin",
    "roles/logging.admin",
    "roles/container.admin",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

# Create a service account key for local Terraform operations (optional, commented out for security)
# Uncomment if needed, but consider alternative authentication methods
# resource "google_service_account_key" "terraform" {
#   service_account_id = google_service_account.terraform.name
# }

