variable "vpc_id" {}
variable "subnet_ids" { type = list(string) }
variable "db_username" {}
variable "db_name" {}
variable "sg_ids" { type = list(string) }
variable "multi_az" { default = false }
variable "instance_class" { default = "db.t3.micro" }
