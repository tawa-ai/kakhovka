# GCP Bootstrap Module

This Terraform module creates the foundational infrastructure required to use Terraform with Google Cloud Platform (GCP), including:

- A Google Cloud Storage (GCS) bucket for storing Terraform state files
- A service account with appropriate permissions for Terraform operations
- IAM bindings for the service account to manage GCP resources

## Features

- Secure remote state storage with versioning enabled
- Lifecycle policies for state file management
- Principle of least privilege for the Terraform service account
- Configurable permissions for different deployment scenarios
- Outputs to easily configure backend for other Terraform projects

## Prerequisites

Before using this module, ensure you have:

1. [Terraform](https://www.terraform.io/downloads.html) installed (version >= 1.0)
2. [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed
3. A GCP project with billing enabled
4. Authentication configured for GCP (e.g., using `gcloud auth application-default login`)
5. Appropriate permissions to create resources in your GCP project:
   - `roles/storage.admin`
   - `roles/iam.serviceAccountAdmin`
   - `roles/resourcemanager.projectIamAdmin`

## Usage

### Basic Usage

```hcl
module "bootstrap" {
  source = "path/to/modules/bootstrap"

  project_id = "my-gcp-project"
  location   = "us-central1"
}
```

### Custom Configuration

```hcl
module "bootstrap" {
  source = "path/to/modules/bootstrap"

  project_id            = "my-gcp-project"
  location              = "us-west1"
  terraform_state_bucket = "custom-terraform-state-bucket"
  service_account_name  = "terraform-automation"
  
  labels = {
    environment = "production"
    team        = "infrastructure"
    cost-center = "platform"
  }
  
  bucket_force_destroy          = true
  uniform_bucket_level_access   = true
}
```

### Using the Module Output for Backend Configuration

After applying the bootstrap module, you can use its outputs to configure the backend for other Terraform configurations:

```hcl
terraform {
  backend "gcs" {
    bucket = "my-gcp-project-terraform-state"
    prefix = "terraform/state"
  }
}
```

## Required Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The GCP project ID where bootstrap resources will be created | `string` | n/a | yes |

## Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | The location (region or multi-region) for the bootstrap resources | `string` | `"us-central1"` | no |
| terraform_state_bucket | Name of the GCS bucket for storing Terraform state | `string` | `"<project_id>-terraform-state"` | no |
| service_account_name | Name of the Terraform service account to create | `string` | `"terraform"` | no |
| labels | A map of labels to apply to bootstrap resources | `map(string)` | `{}` | no |
| bucket_force_destroy | When true, the bucket will be deleted even if it contains objects | `bool` | `false` | no |
| uniform_bucket_level_access | When true, enables uniform bucket-level access for the GCS bucket | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| terraform_state_bucket | The name of the GCS bucket created for Terraform state storage |
| terraform_state_bucket_url | The URL of the GCS bucket created for Terraform state storage |
| terraform_state_bucket_self_link | The self_link of the GCS bucket created for Terraform state storage |
| terraform_service_account_email | The email address of the Terraform service account |
| terraform_service_account_id | The unique ID of the Terraform service account |
| terraform_service_account_name | The fully-qualified name of the Terraform service account |
| backend_configuration | A backend configuration block for use in other Terraform configurations |
| provider_configuration | A provider configuration helper for use in other Terraform configurations |
| backend_terraform_snippet | A terraform backend snippet to use in other Terraform configurations |

## Security Considerations

### Service Account Permissions

The bootstrap module creates a service account with significant permissions within the project. By default, it includes:

- `roles/compute.admin`
- `roles/iam.serviceAccountUser`
- `roles/iam.serviceAccountAdmin`
- `roles/resourcemanager.projectIamAdmin`
- `roles/storage.admin`
- `roles/logging.admin`
- `roles/container.admin`

These broad permissions are necessary for Terraform to manage infrastructure but should be treated carefully. Consider:

1. Limiting permissions based on your specific needs by modifying the role list in main.tf
2. Using workload identity or CI/CD pipelines for secure automation
3. Regularly auditing and rotating service account credentials

### State Bucket Security

The Terraform state files may contain sensitive information. To enhance security:

1. Enable bucket versioning (enabled by default in this module)
2. Consider enabling object level encryption
3. Restrict access to the state bucket (this module grants access only to the Terraform service account)
4. Consider enabling Cloud Audit Logs for bucket access
