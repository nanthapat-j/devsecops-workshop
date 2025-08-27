variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "name_prefix" {
  description = "Name prefix for security groups"
  type        = string
}

variable "tags" {
  description = "Tags to apply to security groups"
  type        = map(string)
  default     = {}
}