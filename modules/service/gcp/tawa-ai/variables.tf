variable "project_id" {
  description = "The GCP project ID where bootstrap resources will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be between 6 and 30 characters, begin with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "github_repo_iam_defintions" {
  description = "Objects defining the IAM federation identity groups for gh actions."
  type = list(object({
    github_branch_pattern         = string
    github_repo                   = string
    permissions                   = list(string)
    service_account_name          = string
    workload_identity_pool_id     = string
    workload_identity_provider_id = string
  }))

  default = []
}
