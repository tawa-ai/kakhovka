variable "project_id" {
  description = "The GCP project ID where bootstrap resources will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be between 6 and 30 characters, begin with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "github_repo" {
  description = "The GitHub repository in the format 'owner/repo' that will be authorized to access GCP"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$", var.github_repo))
    error_message = "GitHub repository must be in the format 'owner/repo'."
  }
}

variable "github_branch_pattern" {
  description = "The GitHub branch pattern to allow for workload identity (e.g., 'main', 'refs/heads/main', or '*' for all branches)"
  type        = string
  default     = "refs/heads/main"
}

variable "service_account_id" {
  description = "ID for the service account."
  type        = string
}

variable "workload_identity_pool_id" {
  description = "Name of the identity pool to bind."
  type        = string
}

variable "workload_identity_pool_name" {
  description = "ID for the Workload Identity Pool (defaults to 'github-pool')"
  type        = string
  default     = "github-pool"
}

variable "workload_identity_provider_id" {
  description = "ID for the Workload Identity Provider (defaults to 'github-provider')"
  type        = string
  default     = "github-provider"
}
