variable "vendor" {
  type    = string
  default = "nicholas"
}
variable "name" {
  type = string
}

variable "env" {
  type = string
}

variable "replication" {
  type    = bool
  default = false
}
variable "replica_region" {
  type = string
}
variable "replica_env" {
  type = string
}


