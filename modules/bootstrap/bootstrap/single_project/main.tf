terraform {
  required_version = ">= 1.0"
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.50.0, < 5.0"
    }
  }
}

provider "google-beta" {
  project = var.project_id
  region  = var.location
}

locals {
  # Determine bucket name based on input or default
  terraform_state_bucket = var.terraform_state_bucket != "" ? var.terraform_state_bucket : "${var.project_id}-terraform-state"

  # Parse GitHub repository details
  github_repo_parts = split("/", var.github_repo)
  github_repo_owner = local.github_repo_parts[0]
  github_repo_name  = local.github_repo_parts[1]

  # Full attributes ID for the workload identity pool and provider
  workload_identity_pool_id     = "${var.project_id}.svc.id.goog/${var.workload_identity_pool_id}"
  workload_identity_provider_id = "${var.project_id}.svc.id.goog/${var.workload_identity_pool_id}/${var.workload_identity_provider_id}"
}

# 1. Set up the bootstrap module to create the foundation resources
module "bootstrap" {
  source = "../../"

  project_id             = var.project_id
  location               = var.location
  terraform_state_bucket = local.terraform_state_bucket
  service_account_name   = var.service_account_name
  labels                 = var.labels
}

# 2. Create a Workload Identity Pool
# This is a collection of identities from various sources (like GitHub)
resource "google_iam_workload_identity_pool" "github_pool" {
  provider                  = google-beta
  project                   = var.project_id
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = "GitHub Actions Identity Pool"
  description               = "Identity pool for GitHub Actions automation"

  # Disable ambient credentials to ensure only explicit bindings work
  disabled = false
}

# 3. Create a Workload Identity Provider within the pool
# This defines the specific external identity provider (GitHub in this case)
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  provider                           = google-beta
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider_id
  display_name                       = "GitHub Actions Provider"
  description                        = "OIDC identity pool provider for GitHub Actions"

  # Configure OIDC attributes specific to GitHub
  oidc {
    # GitHub's OIDC token issuer URL
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  # Define attribute mapping between GitHub's OIDC tokens and Google's attributes
  attribute_mapping = {
    "google.subject"       = "assertion.sub"              # GitHub's subject (repo + workflow + ref)
    "attribute.repository" = "assertion.repository"       # GitHub repository name
    "attribute.owner"      = "assertion.repository_owner" # GitHub repository owner
    "attribute.workflow"   = "assertion.workflow"         # GitHub workflow name
    "attribute.ref"        = "assertion.ref"              # GitHub ref (branch or tag)
  }

  # Configure attribute conditions to restrict which identities can authenticate
  attribute_condition = "attribute.repository==\"${var.github_repo}\" && attribute.ref==\"${var.github_branch_pattern}\""
}

# 4. Create an IAM policy binding that allows the GitHub Workflow to impersonate
# the Terraform service account under specific conditions
resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = module.bootstrap.terraform_service_account_name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
  ]
}

# 5. Add the audit logs to debug any potential problems
resource "google_project_iam_audit_config" "project" {
  project = var.project_id
  service = "allServices"
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
  audit_log_config {
    log_type = "ADMIN_READ"
  }
}
