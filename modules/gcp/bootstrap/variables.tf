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

variable "terraform_state_bucket" {
  description = "Name of the GCS bucket for storing Terraform state (defaults to '<project_id>-terraform-state')"
  type        = string
  default     = ""
}

variable "service_account_email" {
  description = "Email of the Terraform service account to use for main branch"
  type        = string
}

variable "branch_service_account_email" {
  description = "Email of the branch Terraform service account to use for all other branches"
  type        = string
}

variable "labels" {
  description = "A map of labels to apply to bootstrap resources"
  type        = map(string)
  default     = {}
}

variable "bucket_force_destroy" {
  description = "When true, the bucket will be deleted even if it contains objects"
  type        = bool
  default     = false
}

variable "uniform_bucket_level_access" {
  description = "When true, enables uniform bucket-level access for the GCS bucket"
  type        = bool
  default     = true
}

