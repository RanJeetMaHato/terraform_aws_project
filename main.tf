# resource "aws_instance" "web-1" {
#   ami           = var.ami_id
#   instance_type = "t2.micro"
#   key_name      = "jks"
# }

# resource "aws_instance" "web-2" {
#   ami           = var.ami_id
#   instance_type = "t3.micro"
#   key_name      = "jks"
# }

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.name}-vpc"
    Env  = var.env

  }
}

resource "aws_subnet" "pvt_1" {
  availability_zone = var.az1
  cidr_block        = var.pvt_sub-1_cidr
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name = "${var.name}-pvt-sub-1"
    Env  = var.env
  }

}

resource "aws_subnet" "pvt_2" {
  availability_zone = var.az2
  cidr_block        = var.pvt_sub-2_cidr
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name = "${var.name}-pvt-sub-2"
    Env  = var.env
  }

}

resource "aws_subnet" "pub_1" {
  availability_zone       = var.az1
  cidr_block              = var.pub_sub-1_cidr
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-pub-sub-1"
    Env  = var.env
  }

}

resource "aws_subnet" "pub_2" {
  availability_zone       = var.az2
  cidr_block              = var.pub_sub-2_cidr
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-pub-sub-2"
    Env  = "ops"
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.name}-igw"
    Env  = var.env
  }

}

resource "aws_default_route_table" "rt1" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Env = var.env
  }

}

resource "aws_lb_target_group" "tg1" {
  name     = "${var.name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  tags = {
    Env = var.env
  }
}

resource "aws_lb" "alb" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  //subnets            = [for subnet in aws_subnet.public : subnet.id]
  subnets = [aws_subnet.pub_1.id, aws_subnet.pub_2.id]

  tags = {
    Env = var.env
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "attach-alb" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.tg1.arn
}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg1.arn
  }
}