output "account_id" {
  value       = aws_organizations_account.account.id
  description = "ID of the account created"
}

output "email" {
  value       = var.email
  description = "Email of account"
}

output "custom_policy_id" {
  value       = var.create_policy != null ? aws_organizations_policy.custom[0].id : null
  description = "The ID of the custom policy created for this account (if any)"
}

output "all_attached_policy_ids" {
  value = concat(
    var.attach_policy_ids,
    var.create_policy != null ? [aws_organizations_policy.custom[0].id] : []
  )
  description = "List of all policy IDs attached to this account"
}
