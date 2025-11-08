variable "name" {
  description = "Name of the Organizational Unit"
  type        = string

  validation {
    condition     = length(var.name) <= 128
    error_message = "OU name must be 128 characters or less"
  }
}

variable "parent_id" {
  description = "ID of the parent OU or Organization Root"
  type        = string
}

variable "attach_policy_ids" {
  description = "List of existing SCP policy IDs to attach to this OU"
  type        = list(string)
  default     = []
}

variable "create_policy" {
  description = "Optional custom SCP policy to create and attach to this OU"
  type = object({
    name        = string
    description = string
    content     = string
  })
  default = null
}
