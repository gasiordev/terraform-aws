variable "vendor" {
  type = string
}
variable "env" {
  type = string
}
variable "instance_count" {
  type = number
  default = 0
}
variable "ssh_key_name" {
  type = string
}
variable "ssl_certificate" {
  type = string
}
variable "route53_zones" {
  type = map
  default = {}
}
variable "private_db_subnet" {
  type = string
}
variable "db_username" {
  type = string
  default = ""
}
variable "db_password" {
  type = string
  default = ""
}
variable "db_replication_source" {
  type = string
  default = ""
}
