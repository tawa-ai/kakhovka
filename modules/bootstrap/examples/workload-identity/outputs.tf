# Terraform state bucket outputs
output "terraform_state_bucket" {
  description = "The name of the GCS bucket created for Terraform state storage"
  value       = module.bootstrap.terraform_state_bucket
}

output "terraform_state_bucket_url" {
  description = "The URL of the GCS bucket created for Terraform state storage"
  value       = module.bootstrap.terraform_state_bucket_url
}

# Service account outputs
output "terraform_service_account_email" {
  description = "The email address of the Terraform service account"
  value       = module.bootstrap.terraform_service_account_email
}

# Workload Identity Federation outputs
output "workload_identity_pool_name" {
  description = "The name of the workload identity pool"
  value       = google_iam_workload_identity_pool.github_pool.name
}

output "workload_identity_pool_id" {
  description = "The ID of the workload identity pool"
  value       = google_iam_workload_identity_pool.github_pool.id
}

output "workload_identity_provider_name" {
  description = "The name of the workload identity provider"
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}

output "workload_identity_provider_id" {
  description = "The ID of the workload identity provider"
  value       = google_iam_workload_identity_pool_provider.github_provider.id
}

# GitHub Actions configuration helper outputs
output "github_actions_configuration" {
  description = "Configuration values for GitHub Actions workflow"
  value = {
    workload_identity_provider = google_iam_workload_identity_pool_provider.github_provider.name
    service_account            = module.bootstrap.terraform_service_account_email
    project_id                 = var.project_id
    region                     = var.location
  }
}
