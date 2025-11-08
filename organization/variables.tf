variable "aws_allowed_regions" {
  description = "The AWS regions allowed by the organization."
  type        = list(string)
  default     = ["us-east-1", "us-east-2"]
}
