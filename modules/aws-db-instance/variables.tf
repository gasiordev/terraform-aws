variable "vendor" {
  type = string
  default = "nicholas"
}
variable "name" {
  type = string
}
variable "env" {
  type    = string
  default = "dev"
}
variable "engine" {
  type = string
}
variable "engine_version" {
  type = string
}
variable "instance_class" {
  type = string
}
variable "storage" {
  type = number
}
variable "subnet_group" {
  type = string
}
variable "security_groups" {
  type    = list(string)
  default = []
}
variable "create_new_security_group" {
  type = bool
  default = false
}
variable "admin_username" {
  type = string
  default = ""
}
variable "admin_password" {
  type = string
  default = ""
}
variable "replication_source" {
  type    = string
  default = ""
}
variable "route53_zones" {
  type    = map
  default = {}
}
variable "tags" {
  type    = map
  default = {}
}
