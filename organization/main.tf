# The AWS Organization is the foundation of your governance structure.
# This resource creates the organization itself with all features enabled.
# This must be run from the account that will become the management account.
resource "aws_organizations_organization" "this" {
  # Enable essential AWS services to integrate with Organizations
  aws_service_access_principals = [
    "iam.amazonaws.com", # Allows IAM roles to work across accounts
    "sso.amazonaws.com"  # Enables centralized user management via IAM Identity Center
  ]

  # Enables consolidated billing AND all organization features (SCPs, etc.)
  feature_set = "ALL"

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY", # Primary governance tool (SCPs)
  ]
}

# === Service Control Policies (SCPs) ===
# These policies act as guardrails across your entire organization

# Policy 1: Restrict operations to specific AWS regions
# This is crucial for compliance and cost control
resource "aws_organizations_policy" "deny_non_allowed_regions" {
  name        = "DenyNonAllowedRegions"
  description = "Restrict all actions to approved AWS regions only"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyAllOutsideAllowedRegions"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.aws_allowed_regions
          }
        }
      }
    ]
  })
}

# Policy 2: Prevent member accounts from creating their own IAM Identity Center
# This ensures authentication remains centralized in the management account
resource "aws_organizations_policy" "deny_member_account_sso" {
  name        = "DenyMemberAccountSSO"
  description = "Prevent member accounts from creating IAM Identity Center instances"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PreventSSOCreationInMemberAccounts"
        Effect = "Deny"
        Action = [
          "sso:CreateInstance",
          "sso:DeleteInstance"
        ]
        Resource = "*"
      }
    ]
  })
}

# Policy 3: Protect critical organization resources
# This prevents accidental deletion of important governance tools
resource "aws_organizations_policy" "protect_organization_resources" {
  name        = "ProtectOrganizationResources"
  description = "Prevent deletion of critical organization resources"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ProtectCloudTrail"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging"
        ]
        Resource = "*"
      },
      {
        Sid    = "PreventLeavingOrganization"
        Effect = "Deny"
        Action = [
          "organizations:LeaveOrganization"
        ]
        Resource = "*"
      }
    ]
  })
}

# === Attach Policies to Organization Root ===
# Policies attached here apply to EVERY account in the organization

resource "aws_organizations_policy_attachment" "deny_non_allowed_regions" {
  policy_id = aws_organizations_policy.deny_non_allowed_regions.id
  target_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_policy_attachment" "deny_member_account_sso" {
  policy_id = aws_organizations_policy.deny_member_account_sso.id
  target_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_policy_attachment" "protect_organization_resources" {
  policy_id = aws_organizations_policy.protect_organization_resources.id
  target_id = aws_organizations_organization.this.roots[0].id
}
