# Create the Organizational Unit within the AWS Organization hierarchy
# OUs provide logical grouping for accounts with similar compliance/operational needs
resource "aws_organizations_organizational_unit" "this" {
  name      = var.name
  parent_id = var.parent_id
}

# Create a custom SCP specific to this OU's requirements
resource "aws_organizations_policy" "custom" {
  count = var.create_policy != null ? 1 : 0

  name        = var.create_policy.name
  description = var.create_policy.description
  type        = "SERVICE_CONTROL_POLICY"
  content     = var.create_policy.content
}

# Attach the custom policy if created
resource "aws_organizations_policy_attachment" "custom" {
  count = var.create_policy != null ? 1 : 0

  policy_id = aws_organizations_policy.custom[0].id
  target_id = aws_organizations_organizational_unit.this.id
}

# Attach any existing SCPs passed to this module
# These could be organization-wide policies or policies from other OUs
resource "aws_organizations_policy_attachment" "existing" {
  for_each = toset(var.attach_policy_ids)

  policy_id = each.value
  target_id = aws_organizations_organizational_unit.this.id
}
