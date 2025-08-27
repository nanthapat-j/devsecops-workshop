output "cluster_key_arn" {
  description = "ARN of the EKS cluster encryption key"
  value       = aws_kms_key.cluster.arn
}

output "cluster_key_id" {
  description = "ID of the EKS cluster encryption key"
  value       = aws_kms_key.cluster.key_id
}

output "rds_key_arn" {
  description = "ARN of the RDS encryption key"
  value       = aws_kms_key.rds.arn
}

output "rds_key_id" {
  description = "ID of the RDS encryption key"
  value       = aws_kms_key.rds.key_id
}

output "cloudtrail_key_arn" {
  description = "ARN of the CloudTrail encryption key"
  value       = aws_kms_key.cloudtrail.arn
}

output "cloudtrail_key_id" {
  description = "ID of the CloudTrail encryption key"
  value       = aws_kms_key.cloudtrail.key_id
}