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
variable "az_offset" {
  type        = number
  description = "Availability zone for the instance"
  default     = 0
}
variable "ami" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "volume_type" {
  type = string
}
variable "volume_size" {
  type = number
}
variable "key_name" {
  type = string
}
variable "instance_profile" {
  type        = string
  description = "Instance profile to assign to instance - if empty, new role will be created"
  default     = ""
}
variable "instance_count" {
  type        = number
  description = "Number of instances to create"
  default     = 1
}
variable "tags" {
  type        = map
  description = "Vendor tags to assign to instances"
  default     = {}
}
variable "security_groups" {
  type        = list(string)
  description = "Security groups to assign to instances - if empty, new sg will be created"
  default     = []
}
variable "route53_zones" {
  type        = map
  description = "Create IN A entry in specifiec Route 53 zones"
  default     = {}
}
variable "user_data" {
  type    = string
  default = <<EOF
            #!/bin/bash
            echo "Hello World"
            EOF
}
variable "internal" {
  type = boolean
}
