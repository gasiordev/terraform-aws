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
variable "cidr_block" {
  type = string
}
variable "create_rds_base" {
  type    = bool
  default = false
}
