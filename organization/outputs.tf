output "organization_id" {
  value       = aws_organizations_organization.this.id
  description = "The ID of the AWS Organization"
}

output "organization_arn" {
  value       = aws_organizations_organization.this.arn
  description = "The ARN of the AWS Organization"
}

output "organization_root_id" {
  value       = aws_organizations_organization.this.roots[0].id
  description = "The ID of the root of the AWS Organization"
}

output "organization_root_arn" {
  value       = aws_organizations_organization.this.roots[0].arn
  description = "The ARN of the root of the AWS Organization"
}

# Export policy IDs for reference by other modules
output "scp_policy_ids" {
  value = {
    deny_non_allowed_regions       = aws_organizations_policy.deny_non_allowed_regions.id
    protect_organization_resources = aws_organizations_policy.protect_organization_resources.id
    deny_member_account_sso        = aws_organizations_policy.deny_member_account_sso.id
  }
  description = "Map of Service Control Policy IDs"
}
