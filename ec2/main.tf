# 보안 그룹

resource "aws_security_group" "sg" {
  name        = "saju-api-sg-${var.service_type}"
  description = "saju api security group ${var.service_type}"
  vpc_id      = var.vpc_id

  # 인바운드 규칙   
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "APP"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "saju-api-sg-${var.service_type}"
    Service = "saju-${var.service_type}"
  }
}


# EC2
resource "aws_instance" "ec2" {
 ami                    = "ami-04cb1684c278156a3"    # AMI ID     ### ???
 instance_type          = "var.instance_type"        # 인스턴스 유형
 key_name               = "saju-key-${var.service_type}"             # 키 페어
 vpc_security_group_ids = [aws_security_group.sg.id] # 보안그룹 ID
 availability_zone      = "ap-northeast-1a"          # 가용영역       #### 수정해야됨
 user_data              = file(var.user_data_path)      # 사용자 데이타
 # 스토리지 정보
 root_block_device {
   volume_size = 30
   volume_type = "gp3"
 }
 # 태그 설정
 tags = {
   Name    = "saju-api-${var.service_type}"
   Service = "saju-${var.service_type}"
 }
}


# 탄력적 IP 주소 할당
resource "aws_eip" "eip" {
  instance = aws_instance.ec2.id

  tags = {
    Name = "saju-api-${var.service_type}"
    Service = "saju-${var.service_type}"
  }
}

