variable "name_prefix" {
  description = "Name prefix for KMS keys"
  type        = string
}

variable "tags" {
  description = "Tags to apply to KMS keys"
  type        = map(string)
  default     = {}
}