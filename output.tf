output "account_id" {
  description = "AWS account ID - module_v2"
  value       = var.account_id
}

output "current_id" {
  description = "Current AWS account ID - module_v2"
  value       = var.current_id
}

output "region" {
  description = "AWS region - module_v2"
  value       = var.region
}

output "current_region" {
  description = "Your current AWS region - module_v2"
  value       = var.current_region
}

# output "aws_security_group" {
#     description = "the SG that users established - module_v2"
#     value       = aws_security_group.this.id 
# }