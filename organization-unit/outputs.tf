output "id" {
  value       = aws_organizations_organizational_unit.this.id
  description = "The ID of the Organizational Unit"
}

output "arn" {
  value       = aws_organizations_organizational_unit.this.arn
  description = "The ARN of the Organizational Unit"
}

output "name" {
  value       = aws_organizations_organizational_unit.this.name
  description = "The name of the Organizational Unit"
}

output "parent_id" {
  value       = aws_organizations_organizational_unit.this.parent_id
  description = "The ID of the parent OU or Organization Root"
}

output "custom_policy_id" {
  value       = var.create_policy != null ? aws_organizations_policy.custom[0].id : null
  description = "The ID of the custom policy created for this OU (if any)"
}

output "all_attached_policy_ids" {
  value = concat(
    var.attach_policy_ids,
    var.create_policy != null ? [aws_organizations_policy.custom[0].id] : []
  )
  description = "List of all policy IDs attached to this OU"
}
