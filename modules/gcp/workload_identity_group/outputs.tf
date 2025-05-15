# Service account outputs
output "service_account_email" {
  description = "The email address of the Terraform service account"
  value       = google_service_account.terraform.email
}

output "service_account_id" {
  description = "The unique ID of the Terraform service account"
  value       = google_service_account.terraform.id
}

output "service_account_name" {
  description = "The fully-qualified name of the Terraform service account"
  value       = google_service_account.terraform.name
}

output "workload_identity_pool_name" {
  description = "The name of the created workload identity pool"
  value       = google_iam_workload_identity_pool.identity_pool.name
}

output "workload_identity_pool_id" {
  description = "The id of the created workload identity pool"
  value       = google_iam_workload_identity_pool.identity_pool.workload_identity_pool_id
}
