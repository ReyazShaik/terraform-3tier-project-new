vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
azs             = ["ap-south-1a", "ap-south-1b"]
web_ami_id      = "ami-0d0ad8bb301edb745"
app_ami_id      = "ami-0d0ad8bb301edb745"
db_username     = "admin"
db_password     = "changeMeNow!"
db_name         = "production"
