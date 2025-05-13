# Terraform state bucket outputs
output "terraform_state_bucket" {
  description = "The name of the GCS bucket created for Terraform state storage"
  value       = google_storage_bucket.terraform_state.name
}

output "terraform_state_bucket_url" {
  description = "The URL of the GCS bucket created for Terraform state storage"
  value       = "gs://${google_storage_bucket.terraform_state.name}"
}

output "terraform_state_bucket_self_link" {
  description = "The self_link of the GCS bucket created for Terraform state storage"
  value       = google_storage_bucket.terraform_state.self_link
}

# Configuration helper outputs
output "backend_configuration" {
  description = "A backend configuration block for use in other Terraform configurations"
  value = {
    bucket = google_storage_bucket.terraform_state.name
    prefix = "terraform/state"
  }
}

output "provider_configuration" {
  description = "A provider configuration helper for use in other Terraform configurations"
  value = {
    project = var.project_id
    region  = var.location
  }
}

# Template for terraform backend block
output "backend_terraform_snippet" {
  description = "A terraform backend snippet to use in other Terraform configurations"
  value       = <<-EOT
  terraform {
    backend "gcs" {
      bucket = "${google_storage_bucket.terraform_state.name}"
      prefix = "terraform/state"
    }
  }
  EOT
}

