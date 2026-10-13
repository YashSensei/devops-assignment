variable "region" { type = string }
variable "account_id" { type = string }
variable "create_compute" {
  type        = bool
  default     = false
  description = "Enable EC2/S3 only after the network lab works and costs are approved."
}
variable "admin_cidr" {
  type = string
  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "Use the approved tester's narrow CIDR."
  }
}
