resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr

}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "RTa" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "RTb" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  name        = "my_sg"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "HTTP from VPC"
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
    Name = "Web-sg"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "my-tf-test-bucket-poona"

}

resource "aws_instance" "web-server-1" {
  ami                    = "ami-0230bd60aa48260c6"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.sub1.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = base64encode(file("userdata.sh"))


  tags = {
    Name = "web-server-1"
  }

}

resource "aws_instance" "web-server-2" {
  ami                    = "ami-0fc5d935ebf8bc3bc"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.sub2.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = base64encode(file("userdata1.sh"))

  tags = {
    Name = "web-server-2"
  }

}

#create alb

resource "aws_lb" "my_alb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "web"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "mytg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
  health_check {
    path = "/"
    port = "traffic-port"
  }

}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web-server-1.id
  port             = 80

}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web-server-2.id
  port             = 80

}

resource "aws_lb_listener" "listener1" {
  load_balancer_arn = aws_lb.my_alb.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }

}

output "loadbalancerdns" {
  value = aws_lb.my_alb.dns_name
}
