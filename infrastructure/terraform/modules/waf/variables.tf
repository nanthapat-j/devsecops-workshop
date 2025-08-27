variable "name_prefix" {
  description = "Name prefix for WAF resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_geo_blocking" {
  description = "Enable geographic blocking"
  type        = bool
  default     = false
}

variable "allowed_countries" {
  description = "List of allowed country codes for geo blocking"
  type        = list(string)
  default     = ["TH", "SG", "US"]
}

variable "tags" {
  description = "Tags to apply to WAF resources"
  type        = map(string)
  default     = {}
}