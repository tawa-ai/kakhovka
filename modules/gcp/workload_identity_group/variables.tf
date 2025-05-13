variable "project_id" {
  description = "The GCP project ID where bootstrap resources will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be between 6 and 30 characters, begin with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "permissions" {
  description = "The permissions to grant to the workload identity group."
  type        = list(any)
  default = [
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/storage.admin",
    "roles/logging.admin",
    "roles/container.admin",
  ]
}

variable "service_account_id" {
  description = "Name to give the service account."
  type        = string
  default     = "svc"
}

variable "workload_identity_pool_id" {
  description = "ID for the Workload Identity Pool (defaults to 'github-pool')"
  type        = string
  default     = "github-pool"
}
