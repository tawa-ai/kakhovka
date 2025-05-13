# GCP Bootstrap with Workload Identity Federation for GitHub Actions

This example demonstrates how to set up the GCP bootstrap module with Workload Identity Federation to enable secure authentication between GitHub Actions and Google Cloud Platform without using service account keys.

## What is Workload Identity Federation?

Workload Identity Federation allows external identities (like GitHub Actions) to act as Google Cloud service accounts by establishing a trust relationship between an external identity provider and Google Cloud. This approach:

- **Eliminates service account keys**: No need to create, distribute, or manage long-lived service account keys
- **Provides short-lived access**: Uses temporary credentials rather than persistent access tokens
- **Offers granular control**: Limit access based on specific repositories, branches, and other attributes
- **Follows security best practices**: Adheres to the principle of least privilege

## Prerequisites

Before using this example, ensure you have:

1. A GCP project with billing enabled
2. Owner or Editor permissions on the GCP project
3. A GitHub repository where you want to run Terraform
4. The following APIs enabled in your GCP project:
   - IAM API (`iam.googleapis.com`)
   - IAM Credentials API (`iamcredentials.googleapis.com`)
   - Security Token Service API (`sts.googleapis.com`)
   - Cloud Resource Manager API (`cloudresourcemanager.googleapis.com`)
   - Storage API (`storage.googleapis.com`)

## Step-by-Step Setup Instructions

### 1. Configure Terraform variables

Create a `terraform.tfvars` file with your specific values:

```hcl
project_id           = "your-gcp-project-id"
location             = "us-central1"
github_repo          = "your-org/your-repo"
github_branch_pattern = "refs/heads/main"  # Or customize to your needs
```

### 2. Apply the Terraform configuration

Initialize and apply the Terraform configuration:

```bash
terraform init
terraform apply
```

This will:
- Create a GCS bucket for Terraform state storage
- Create a service account for Terraform operations
- Set up Workload Identity Federation for GitHub Actions
- Configure IAM bindings to allow the GitHub workflow to impersonate the service account

### 3. Configure your GitHub Actions workflow

After applying the Terraform configuration, use the output values to configure your GitHub Actions workflow. You can use the `github_actions_workflow_snippet` output directly, or customize it to your needs:

```yaml
name: Terraform with Workload Identity Federation

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

permissions:
  contents: read
  id-token: write  # Required for requesting the JWT

jobs:
  terraform:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Set up Cloud SDK
      uses: google-github-actions/setup-gcloud@v1
      
    - name: Authenticate to Google Cloud
      id: auth
      uses: google-github-actions/auth@v1
      with:
        workload_identity_provider: 'projects/123456789/locations/global/workloadIdentityPools/github-pool/providers/github-provider'
        service_account: 'github-actions@your-project-id.iam.gserviceaccount.com'
    
    - name: Set up Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: '1.0.0'
        
    - name: Terraform Init
      run: terraform init -backend-config="bucket=your-terraform-state-bucket"
      
    - name: Terraform Plan
      run: terraform plan -out=tfplan
      
    - name: Terraform Apply
      if: github.event_name == 'push' && github.ref == 'refs/heads/main'
      run: terraform apply -auto-approve tfplan
```

Replace the placeholder values with the actual values from your Terraform outputs.

## Security Best Practices

### 1. Restrict access by repository and branch

This example restricts the workload identity federation to a specific GitHub repository and branch. You can make it even more restrictive by adding more conditions:

```hcl
attribute_condition = "attribute.repository==\"${var.github_repo}\" && attribute.ref==\"${var.github_branch_pattern}\" && attribute.workflow==\"terraform.yml\""
```

### 2. Use the principle of least privilege

The service account created by the bootstrap module has sufficient permissions to manage resources, but consider restricting it further based on your specific needs.

### 3. Enable audit logging

Enable Data Access audit logs for your GCP project to monitor and audit all access attempts:

```hcl
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
```
