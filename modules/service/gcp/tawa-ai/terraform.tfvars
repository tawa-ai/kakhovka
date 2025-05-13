project_id = "tawa-ai"

github_repo_iam_defintions = [{
  github_branch_pattern = "*"
  permissions = ["roles/viewer",
    "roles/browser",
    "roles/iam.securityReviewer",
    "roles/iam.workloadIdentityPoolViewer",
    "roles/iam.serviceAccountUser",
    "roles/storage.objectViewer",
  "roles/storage.objectCreator"]
  github_repo                   = "tawa-ai/templafirm"
  service_account_name          = "templafirm-gh-actions"
  workload_identity_pool_id     = "templafirm-pool"
  workload_identity_provider_id = "templafirm-provider"
}]
