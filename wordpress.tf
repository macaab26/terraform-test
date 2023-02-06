module "wordpress" {
  source  = "atpoirie/wordpress-ecs/aws"
  version = "1.0.0"
   ecs_service_subnet_ids = module.vpc.private_subnets
   lb_subnet_ids = module.vpc.public_subnets
   db_subnet_group_subnet_ids = module.vpc.database_subnets
}