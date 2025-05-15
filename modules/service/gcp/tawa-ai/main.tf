terraform {
  backend "gcs" {
    bucket = "tawa-ai-terraform-state"
    prefix = "terraform/state"
  }
}

module "workload_identity_pool" {
  for_each = {
    for index, v in var.github_repo_iam_defintions : index => v
  }

  source = "../../../gcp/workload_identity_group"

  permissions               = each.value.permissions
  project_id                = var.project_id
  service_account_id        = each.value.service_account_name
  workload_identity_pool_id = each.value.workload_identity_pool_id
}
