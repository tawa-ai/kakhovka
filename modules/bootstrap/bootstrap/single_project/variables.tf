variable "project_id" {
  description = "The GCP project ID where bootstrap resources will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be between 6 and 30 characters, begin with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "location" {
  description = "The location (region or multi-region) for the bootstrap resources"
  type        = string
  default     = "us-central1"

  validation {
    condition     = can(regex("^(us|eu|asia|northamerica|southamerica|australia)(-\\w+)?$", var.location))
    error_message = "Location must be a valid GCP region or multi-region."
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

variable "terraform_state_bucket" {
  description = "Name of the GCS bucket for storing Terraform state (defaults to '<project_id>-terraform-state')"
  type        = string
  default     = ""
}

variable "service_account_name" {
  description = "Name of the Terraform service account to create"
  type        = string
  default     = "github-actions"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_-]{2,28}[a-zA-Z0-9]$", var.service_account_name))
    error_message = "Service account name must be between 4 and 30 characters and match the pattern [a-zA-Z][a-zA-Z0-9_-]{2,28}[a-zA-Z0-9]."
  }
}

variable "workload_identity_pool_id" {
  description = "ID for the Workload Identity Pool (defaults to 'github-pool')"
  type        = string
  default     = "github-pool"
}

variable "workload_identity_provider_id" {
  description = "ID for the Workload Identity Provider (defaults to 'github-provider')"
  type        = string
  default     = "github-provider"
}

variable "labels" {
  description = "A map of labels to apply to bootstrap resources"
  type        = map(string)
  default = {
    managed-by = "terraform"
    purpose    = "ci-cd"
  }
}

