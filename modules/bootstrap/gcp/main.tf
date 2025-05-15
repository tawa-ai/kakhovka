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
}

module "workload_identity_pool" {
  source = "../../gcp/workload_identity_group"

  project_id                = var.project_id
  service_account_id        = var.service_account_name
  terraform_state_bucket    = local.terraform_state_bucket
  workload_identity_pool_id = var.workload_identity_pool_id
}

module "workload_identity_pool_branch" {
  source = "../../gcp/workload_identity_group"

  project_id                = var.project_id
  service_account_id        = "${var.service_account_name}-branch"
  terraform_state_bucket    = local.terraform_state_bucket
  workload_identity_pool_id = "${var.workload_identity_pool_id}-branch"
}

module "bootstrap" {
  source = "../../gcp/bootstrap"

  service_account_email        = module.workload_identity_pool.service_account_email
  branch_service_account_email = module.workload_identity_pool_branch.service_account_email
  project_id                   = var.project_id
  location                     = var.location
  terraform_state_bucket       = local.terraform_state_bucket
  labels                       = var.labels
}

module "workload_identity_pool_gh_binding" {
  source                        = "../../gcp/gh_actions"
  github_branch_pattern         = "main"
  github_repo                   = var.github_repo
  project_id                    = var.project_id
  service_account_id            = module.workload_identity_pool.service_account_id
  workload_identity_pool_id     = module.workload_identity_pool.workload_identity_pool_id
  workload_identity_pool_name   = module.workload_identity_pool.workload_identity_pool_name
  workload_identity_provider_id = var.workload_identity_provider_id
}

module "workload_identity_pool_branch_gh_binding" {
  source                        = "../../gcp/gh_actions"
  github_branch_pattern         = "*"
  github_repo                   = var.github_repo
  project_id                    = var.project_id
  service_account_id            = module.workload_identity_pool_branch.service_account_id
  workload_identity_pool_id     = module.workload_identity_pool_branch.workload_identity_pool_id
  workload_identity_pool_name   = module.workload_identity_pool_branch.workload_identity_pool_name
  workload_identity_provider_id = var.workload_identity_provider_id
}

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
