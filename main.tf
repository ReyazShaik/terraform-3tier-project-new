module "network" {
  source          = "./modules/network"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  db_subnets      = var.db_subnets
  azs             = var.azs
}

module "web" {
  source           = "./modules/web"
  vpc_id           = module.network.vpc_id
  subnets          = module.network.private_subnets
  alb_subnets      = module.network.public_subnets
  instance_type    = var.web_instance_type
  ami_id           = var.web_ami_id
  desired_capacity = 2
  min_size         = 2
  max_size         = 4
  sg_ids           = [module.network.web_sg_id]
  app_alb_dns      = module.app.alb_dns
  alb_sg_id        = module.network.web_alb_sg_id
}

module "app" {
  source           = "./modules/app"
  vpc_id           = module.network.vpc_id
  subnets          = module.network.private_subnets
  instance_type    = var.app_instance_type
  ami_id           = var.app_ami_id
  desired_capacity = 2
  min_size         = 2
  max_size         = 4
  sg_ids           = [module.network.app_sg_id]
  alb_subnets      = module.network.private_subnets
  alb_sg_id        = module.network.app_alb_sg_id
}

module "db" {
  source         = "./modules/db"
  vpc_id         = module.network.vpc_id
  subnet_ids     = module.network.private_db_subnets
  db_username    = var.db_username
  db_name        = var.db_name
  sg_ids         = [module.network.db_sg_id]
  multi_az       = true
  instance_class = var.db_instance_class
}

