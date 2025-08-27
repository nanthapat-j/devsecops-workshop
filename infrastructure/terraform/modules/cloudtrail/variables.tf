variable "trail_name" {
  description = "Name of the CloudTrail"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for CloudTrail encryption"
  type        = string
}

variable "include_global_service_events" {
  description = "Include global service events in the trail"
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Make this trail multi-region"
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Enable log file validation"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to CloudTrail resources"
  type        = map(string)
  default     = {}
}