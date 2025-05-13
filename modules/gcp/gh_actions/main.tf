resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = var.workload_identity_pool_id
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
    "google.subject"             = "assertion.sub"              # GitHub's subject (repo + workflow + ref)
    "attribute.repository"       = "assertion.repository"       # GitHub repository name
    "attribute.repository_owner" = "assertion.repository_owner" # GitHub repository owner
    "attribute.workflow"         = "assertion.workflow"         # GitHub workflow name
    "attribute.ref"              = "assertion.ref"              # GitHub ref (branch or tag)
  }

  # Configure attribute conditions to restrict which identities can authenticate
  attribute_condition = var.github_branch_pattern == "*" ? (
    "assertion.repository==\"${var.github_repo}\""
    ) : (
    "assertion.repository==\"${var.github_repo}\" && assertion.ref==\"${local.branch_ref}\""
  )
}

locals {
  # Handle branch pattern formatting - only add refs/heads/ if not already present
  branch_ref = var.github_branch_pattern == "*" ? "*" : (
    can(regex("^refs/heads/", var.github_branch_pattern)) ? var.github_branch_pattern : "refs/heads/${var.github_branch_pattern}"
  )

  # Construct the appropriate principalSet based on branch pattern
  principal_set = var.github_branch_pattern == "*" ? (
    "principalSet://iam.googleapis.com/${var.workload_identity_pool_name}/attribute.repository/${var.github_repo}"
    ) : (
    "principalSet://iam.googleapis.com/${var.workload_identity_pool_name}/attribute.repository/${var.github_repo}/attribute.ref/${local.branch_ref}"
  )
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = var.service_account_id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    local.principal_set
  ]
}
