variable "env" {
  type = string
}
variable "vpc" {
  type = string
}
variable "private_subnet_a" {
  type = string
}
variable "private_subnet_b" {
  type = string
}
variable "private_subnet_c" {
  type = string
}
variable "public_subnet_a" {
  type = string
}
variable "public_subnet_b" {
  type = string
}
variable "public_subnet_c" {
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
