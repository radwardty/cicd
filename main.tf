terraform {
  required_providers {
    aws = {
        source = "hashcorp/aws"
        version = "5.77.0"
    }
  }
}

# AWS region
provider "aws" {
    region = "ap-northeast-1"
  
}

#[공통]
#service_type : prod | test
#default vpc : vpc-020c2063ea1c5566e

# ALB
# subnet_ids = default vpd의 서브넷 정보를 가져온다
module "alb" {
    source = "./alb"
    service_type = var.service_type
    vpc_id = var.vpc_id
    subnet_ids = ["subnet-05f76f1e5dafa71d6", "subnet-0f248007d31fddb50"]
    depends_on = [ module.ec2 ]
  
}

# EC2
module "ec2" {
    source = "./ec2"
    service_type = var.service_type
    vpc_id = var.vpc_id
    instance_type = "t2.micro"
    user_data_path = "./ec2/userdata.sh"
      
}

# RDS
module "rds" {
    source = "./rds"
    service_type = var.service_type
    vpc_id = var.vpc_id
    instance_class = "db.t4g.micro"     ### 다를수있음
    username = "admin"
    password = "qewr1324"
    publicly_accessible = true
  
}

# S3
module "s3" {
    source = "./s3"
    service_type = var.service_type
    vpc_id = var.vpc_id
    bucket = "saju-front-${var.service_type}-07"
  
}