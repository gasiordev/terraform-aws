variable "vpc_attributes" {
  type = object({
    vpc_id = string,
    subnet_id = object({
      private = object({
        a = string,
        b = string,
        c = string,
      }),
      public = object({
        a = string,
        b = string,
        c = string,
      })
    }),
    route_table_id = object({
      private = object({
        a = string,
        b = string,
        c = string,
      }),
      public = string,
    }),
    cidr_block = string,
  })
}
