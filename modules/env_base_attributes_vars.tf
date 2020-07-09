variable "env_base_attributes" {
  type = object({
    sg = {
      instance = string
      lb_internal = string
      lb_external = string
    },
    db_subnet_id = {
      private = string,
      public = string
    }
  })
}
