output "prod_sg_instance" {
  value = module.aws_env_base_prod.sg_instance
}
output "prod_sg_lb_internal" {
  value = module.aws_env_base_prod.sg_lb_internal
}
output "prod_sg_lb_external" {
  value = module.aws_env_base_prod.sg_lb_external
}
output "prod_db_subnet_private" {
  value = module.aws_env_base_prod.db_subnet_private
}
output "prod_db_subnet_public" {
  value = module.aws_env_base_prod.db_subnet_public
}
