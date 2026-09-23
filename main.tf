provider "aws" {
  region = var.aws_region
}

# ==========================================
# 1. RED (VPC, Subredes y Salida a Internet)
# ==========================================
resource "aws_vpc" "vpc_test" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_test.id
}

resource "aws_subnet" "sub_a" {
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub_b" {
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc_test.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.sub_a.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.sub_b.id
  route_table_id = aws_route_table.rt.id
}

# ==========================================
# 2. SEGURIDAD (Security Groups)
# ==========================================
resource "aws_security_group" "sg_alb" {
  name   = "sg_alb"
  vpc_id = aws_vpc.vpc_test.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3002
    to_port     = 3002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3003
    to_port     = 3003
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3004
    to_port     = 3004
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_ec2" {
  name   = "sg_ec2"
  vpc_id = aws_vpc.vpc_test.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }
  ingress {
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }
  ingress {
    from_port       = 3002
    to_port         = 3002
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }
  ingress {
    from_port       = 3003
    to_port         = 3003
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }
  ingress {
    from_port       = 3004
    to_port         = 3004
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================================
# 3. BALANCEADOR DE CARGA (ALB)
# ==========================================
resource "aws_lb" "alb" {
  name               = "test-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = [aws_subnet.sub_a.id, aws_subnet.sub_b.id]
}

# ==========================================
# 4. TARGET GROUPS 
# ==========================================
resource "aws_lb_target_group" "tg_front" {
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_test.id
}
resource "aws_lb_target_group" "tg_3001" {
  port     = 3001
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_test.id
  health_check {
    matcher = "200,404"
  }
}
resource "aws_lb_target_group" "tg_3002" {
  port     = 3002
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_test.id
  health_check {
    matcher = "200,404"
  }
}
resource "aws_lb_target_group" "tg_3003" {
  port     = 3003
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_test.id
  health_check {
    matcher = "200,404"
  }
}
resource "aws_lb_target_group" "tg_3004" {
  port     = 3004
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_test.id
  health_check {
    matcher = "200,404"
  }
}

# ==========================================
# 5. LISTENERS 
# ==========================================
resource "aws_lb_listener" "list_front" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_front.arn
  }
}
resource "aws_lb_listener" "list_3001" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 3001
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_3001.arn
  }
}
resource "aws_lb_listener" "list_3002" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 3002
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_3002.arn
  }
}
resource "aws_lb_listener" "list_3003" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 3003
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_3003.arn
  }
}
resource "aws_lb_listener" "list_3004" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 3004
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_3004.arn
  }
}

# ==========================================
# 6. INSTANCIA EC2 Y USER DATA
# ==========================================
resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sub_a.id
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]
  
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y git docker.io docker-compose-v2
              systemctl enable --now docker
              git clone https://github.com/Ignaciov1/arquitectura_microservicios.git /home/ubuntu/app
              cd "/home/ubuntu/app/1.6.4 desarrolloApp-ACT1.6"
              docker compose build
              docker compose up -d
              EOF

  tags = {
    Name = "Servidor-Prueba-EscolarOnline"
  }
}

# ==========================================
# 7. CONEXIÓN AL BALANCEADOR
# ==========================================
resource "aws_lb_target_group_attachment" "attach_front" {
  target_group_arn = aws_lb_target_group.tg_front.arn
  target_id        = aws_instance.app.id
}
resource "aws_lb_target_group_attachment" "attach_3001" {
  target_group_arn = aws_lb_target_group.tg_3001.arn
  target_id        = aws_instance.app.id
}
resource "aws_lb_target_group_attachment" "attach_3002" {
  target_group_arn = aws_lb_target_group.tg_3002.arn
  target_id        = aws_instance.app.id
}
resource "aws_lb_target_group_attachment" "attach_3003" {
  target_group_arn = aws_lb_target_group.tg_3003.arn
  target_id        = aws_instance.app.id
}
resource "aws_lb_target_group_attachment" "attach_3004" {
  target_group_arn = aws_lb_target_group.tg_3004.arn
  target_id        = aws_instance.app.id
}