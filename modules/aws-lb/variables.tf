variable "vendor" {
  type    = string
  default = "nicholas"
}
variable "env" {
  type    = string
  default = "dev"
}
variable "name" {
  type = string
}
variable "region" {
  type = string
}
variable "availability_zones" {
  type = list(string)
}
variable "ssl_policy" {
  type = string
}
variable "ssl_certificate" {
  type = string
}
variable "instance_ids" {
  type = list(string)
}
variable "instance_security_group" {
  type = string
}
variable "listeners" {
  type    = map
  default = {
    "HTTPS" = 443
  }
}
variable "target_group_port" {
  type    = number
  default = 80
}
variable "target_group_protocol" {
  type    = string
  default = "HTTP"
}
variable "target_group_healthcheck_path" {
  type    = string
  default = "/"
}

variable "tags" {
  type        = map
  description = "Vendor tags to assign to load balancer"
  default     = {}
}
variable "security_groups" {
  type        = list(string)
  description = "Security groups to assign to load balancer - if empty, new sg will be created"
  default     = []
}
variable "route53_zones" {
  type        = map
  description = "Create IN A entry in specifiec Route 53 zones"
  default     = {}
}
variable "internal" {
  type = bool
}
