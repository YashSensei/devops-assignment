variable "region" { type = string }
variable "account_id" {
  type = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "Provide the reviewed 12-digit AWS account ID."
  }
}
variable "project" {
  type    = string
  default = "kitledger-24bcs10164"
}
variable "kubernetes_version" {
  type        = string
  description = "Select a currently supported EKS version after account/region approval."
}
variable "admin_cidrs" {
  type = list(string)
  validation {
    condition     = length(var.admin_cidrs) > 0 && alltrue([for cidr in var.admin_cidrs : can(cidrhost(cidr, 0)) && cidr != "0.0.0.0/0"])
    error_message = "Use specific administrator CIDRs, never the entire internet."
  }
}
variable "instance_type" {
  type    = string
  default = "t3.medium"
}
