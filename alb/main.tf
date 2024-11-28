# Security Group
resource "aws_security_group" "sg" {
  name        = "saju-alb-sg-${var.service_type}"
  description = "saju alb sg ${var.service_type}"
  vpc_id      = var.vpc_id
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name    = "saju-alb-sg-${var.service_type}"
    Service = "saju-${var.service_type}"
  }
}

# ALB
resource "aws_lb" "alb" {
  name                       = "saju-alb-${var.service_type}"
  internal                   = false # 인터넷 경계
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.sg.id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = false # 삭제 방지 - 비활성화
  tags = {
    Name    = "saju-alb-${var.service_type}"
    Service = "saju-${var.service_type}"
  }
}

# 리스너
resource "aws_lb_listener" "routing" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn # 대상 그룹 지정
  }
}

# 대상 그룹
resource "aws_lb_target_group" "tg" {
  name        = "saju-tg-${var.service_type}"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
  health_check {
    enabled  = true
    path     = "/"
    protocol = "HTTP"
    # 고급 상태 검사
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    matcher             = "200"
  }

  tags = {
    Name    = "saju-tg-${var.service_type}"
    Service = "saju-${var.service_type}"
  }
}

# 대상 등록
resource "aws_lb_target_group_attachment" "attachment" {
  count            = length(data.aws_instances.tag.ids)                ##### 1로 변경
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = element(data.aws_instances.tag.ids, count.index)
  port             = 3000
}

# 대상 인스턴스 정보
data "aws_instances" "tag" {
  instance_tags = {
    Name = "saju-api-${var.service_type}"
  }
}
