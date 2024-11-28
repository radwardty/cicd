# 보안 그룹
resource "aws_security_group" "sg" {
 name        = "saju-db-sg-${var.service_type}"
 description = "saju db sg ${var.service_type}"
 vpc_id      = var.vpc_id


 ingress {
   description = "RDS MySQL 3306"
   from_port   = 3306
   to_port     = 3306
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
 tags = {
   Name    = "saju-db-sg-${var.service_type}"
   Service = "saju-${var.service_type}"
 }


}


# RDS
resource "aws_db_instance" "rds" {
 instance_class         = var.instance_class
 identifier             = "saju-db-${var.service_type}"
 engine                 = "mysql"
 engine_version         = "8.0.39"
 username               = var.username
 password               = var.password
 parameter_group_name   = "default.mysql8.0"
 allocated_storage      = 20
 max_allocated_storage  = 1000
 publicly_accessible    = var.publicly_accessible
 vpc_security_group_ids = [aws_security_group.sg.id]
 availability_zone      = "ap-northeast-1a"
 port                   = 3306
 skip_final_snapshot    = true
 tags = {
   Name    = "saju-db-${var.service_type}"
   Service = "saju-${var.service_type}"
 }
}
