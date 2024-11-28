# EC2 -EIP
output "eip_ip" {
    value = module.ec2.eip_ip
}

#RDS endpoint
output "rds_endpoint" {
    value = module.rds.rds_endpoint
}

#S3 - endpoint
output "s3_endpoint" {
    value = module.s3.s3_endpoint
}

# ALB -dns name
output "alb_dns_name" {
    value = module.alb.alb_dns_name  
}

