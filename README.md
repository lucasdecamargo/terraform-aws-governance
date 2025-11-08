# Terraform AWS Governance Modules

A collection of Terraform modules that codify the governance pillars featured in the blog post *IaC Startup on AWS: Governance Pillars*.[^blog]

The modules help you bootstrap an AWS Organization with opinionated Service Control Policies (SCPs), create Organizational Units (OUs), and provision member accounts with consistent guardrails. They are designed to be composed together or orchestrated with tools such as Terragrunt.

[^blog]: Lucas de Camargo, [IaC Startup on AWS: Governance Pillars](https://dev.to/lucasdecamargo/iac-startup-on-aws-governance-pillars-3bam-temp-slug-3969599?preview=21dcb7ccd66d36a1730aa6062e28e4f5c8a7ef656e445fada1b7bcd8dbd6eca8f55912014d8ce0d8c00b1a7c4a3e6e286c3d643b9d2a0919ac4bfb12)

## Module Overview

- `organization`: Creates the AWS Organization, enables key services, and attaches baseline SCPs that lock operations to approved regions, protect logging, and keep IAM Identity Center centralized.
- `organization-unit`: Provisions an OU under any parent and allows you to attach existing SCPs or create a custom policy for that branch of the hierarchy.
- `account`: Automates new AWS member accounts with optional billing console access, inherited SCP attachments, and per-account guardrails.

### organization

- Enables IAM and IAM Identity Center integration, sets the feature set to `ALL`, and turns on SCP support for the entire organization.
- Ships three default SCPs: deny non-approved regions, prevent member accounts from operating their own IAM Identity Center instances, and block deletion of critical audit resources.
- Immediately attaches those SCPs to the organization root so every current and future account inherits them.

```24:44:organization/main.tf
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyAllOutsideAllowedRegions"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
// ... existing code ...
```

Inputs

- `aws_allowed_regions` *(list(string), default `["us-east-1", "us-east-2"]`)* – regions where workloads are permitted.

Outputs

- `organization_id`, `organization_arn`, `organization_root_id`, `organization_root_arn`
- `scp_policy_ids` – map containing the three baseline SCP IDs for composability with other modules.

### organization-unit

- Creates an OU under any parent (another OU or the organization root) and supports a scoped custom SCP.
- Accepts a list of policy IDs to attach, making it easy to cascade the baseline SCPs from the organization module.
- Outputs identifiers for the newly created OU and all policy IDs currently applied to it.

```1:16:organization-unit/main.tf
resource "aws_organizations_organizational_unit" "this" {
  name      = var.name
  parent_id = var.parent_id
}

resource "aws_organizations_policy" "custom" {
  count = var.create_policy != null ? 1 : 0
// ... existing code ...
```

Key inputs

- `name` *(string, required)* – validated to 128 characters.
- `parent_id` *(string, required)* – ID of the root or parent OU.
- `attach_policy_ids` *(list(string), default `[]`)* – SCPs that should apply to this OU.
- `create_policy` *(object, default `null`)* – optional inline SCP definition.

### account

- Wraps `aws_organizations_account` and ignores name/email drift to avoid accidental recreation of immutable accounts.
- Optionally creates a custom account-specific SCP and/or attaches reusable policies passed via IDs.
- Exposes the AWS account ID, email, policy IDs, and a helper output concatenating all attached SCPs.

```1:20:account/main.tf
resource "aws_organizations_account" "account" {
  name                       = var.name
  email                      = var.email
  iam_user_access_to_billing = var.billing_access ? "ALLOW" : "DENY"

  lifecycle {
    ignore_changes = [name, email]
  }
}
// ... existing code ...
```

Key inputs

- `name` *(string, required)* – friendly name for the account.
- `email` *(string, required)* – unique email for the delegated account owner.
- `billing_access` *(bool, default `false`)* – allow IAM users to access the billing console.
- `attach_policy_ids` *(list(string), default `[]`)* – SCPs to inherit.
- `create_policy` *(object, default `null`)* – optional custom SCP definition.

## Getting Started

1. Install Terraform (>= 1.5 recommended) and configure AWS credentials that have permissions to manage AWS Organizations.
2. Pick a state management strategy (local, S3 backend, etc.) suitable for running from the management account.
3. Instantiate the modules in the recommended order: organization → organization units → accounts.

Example root module:

```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "organization" {
  source             = "./organization"
  aws_allowed_regions = ["us-east-1", "us-east-2"]
}

module "security_ou" {
  source            = "./organization-unit"
  name              = "security"
  parent_id         = module.organization.organization_root_id
  attach_policy_ids = values(module.organization.scp_policy_ids)
}

module "security_account" {
  source            = "./account"
  name              = "security-tools"
  email             = "security-tools@example.com"
  attach_policy_ids = module.security_ou.all_attached_policy_ids
}
```

## Recommendations

- Execute the organization module from the management account only once; subsequent applies should run from the same state to avoid recreating the organization.
- Start with a small set of OUs and accounts, then iterate as your governance needs expand—Terraform makes it easy to reorganize later.
- Combine these modules with Terragrunt or a higher-level wrapper to separate environments, manage remote state, and introduce additional governance controls (logging, security baselines, budgets).

## Contributing

Issues and pull requests are welcome. Please fork the repository, create a feature branch, and submit a PR describing the change.

## License

This project is licensed under the MIT License. See `LICENSE` for details.
