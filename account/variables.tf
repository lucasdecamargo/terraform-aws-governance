variable "name" {
  description = "Name for the account to be created"
}

variable "email" {
  description = "Email address for this account, needs to be unique"
}

variable "billing_access" {
  description = "Whether the account should have access to the AWS Billing Console"
  type        = bool
  default     = false
}

variable "attach_policy_ids" {
  description = "List of existing SCP policy IDs to attach to this account"
  type        = list(string)
  default     = []
}

variable "create_policy" {
  description = "Optional custom SCP policy to create and attach to this account"
  type = object({
    name        = string
    description = string
    content     = string
  })
  default = null
}
