locals {
  tags = merge(var.common_tags, {
    Project = var.project_name
  })
}

module "vpc" {
  source = "./modules/vpc"

  project_name          = var.project_name
  vpc_cidr              = var.vpc_cidr
  azs                   = var.azs
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  single_nat_gateway    = var.single_nat_gateway
  tags                  = local.tags
}

module "security" {
  source = "./modules/security"

  project_name   = var.project_name
  vpc_id         = module.vpc.vpc_id
  container_port = var.container_port
  db_port        = 5432
  tags           = local.tags
}

module "alb" {
  source = "./modules/alb"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  alb_sg_id          = module.security.alb_sg_id
  container_port     = var.container_port
  health_check_path  = var.health_check_path
  certificate_arn    = var.certificate_arn
  tags               = local.tags
}

module "rds" {
  source = "./modules/rds"

  project_name             = var.project_name
  private_subnet_ids       = module.vpc.private_subnet_ids
  rds_sg_id                = module.security.rds_sg_id
  db_name                  = var.db_name
  db_username              = var.db_username
  instance_class           = var.db_instance_class
  allocated_storage        = var.db_allocated_storage
  multi_az                 = var.db_multi_az
  deletion_protection      = var.db_deletion_protection
  backup_retention_period = var.db_backup_retention_period
  tags                     = local.tags
}

module "ecs" {
  source = "./modules/ecs"

  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  ecs_sg_id            = module.security.ecs_sg_id
  target_group_arn     = module.alb.target_group_arn
  alb_arn_suffix       = module.alb.alb_arn_suffix
  container_port       = var.container_port
  container_image      = var.container_image
  instance_type        = var.instance_type
  asg_min_size         = var.asg_min_size
  asg_max_size         = var.asg_max_size
  asg_desired_capacity = var.asg_desired_capacity
  task_cpu             = var.task_cpu
  task_memory          = var.task_memory
  desired_task_count   = var.desired_task_count

  environment = merge(var.container_environment, {
    DB_HOST = module.rds.db_address
    DB_NAME = module.rds.db_name
  })
  db_secret_arn           = module.rds.secret_arn
  create_db_secret_access = true

  tags = local.tags
}
