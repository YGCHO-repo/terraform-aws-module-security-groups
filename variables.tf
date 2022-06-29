variable "region" {
  description = "AWS Region - module_v2"
  type        = string
}

variable "current_region" {
  description = "Your AWS current region - module_v2"
  type        = string
}

variable "account_id" {
  description = "Allowed AWS account ID - module_v2"
  type        = string
}

variable "current_id" {
  description = "Yor current acccount ID - module_v2"
  type        = string
}

variable "prefix" {
  description = "prefix for aws resource and tags - module_v2"
  type        = string
}

variable "name" {
  description = "security group's name - module_v2"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "vpc_id - module_v2"
  type        = string
}

variable "tags" {
  description = "tags map - module_v2"
  type        = map(string)
}

variable "rules" {
  description = "security group's rules - module_v2"
  type        = map(any)
}