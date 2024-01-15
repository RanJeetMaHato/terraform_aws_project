# resource "aws_instance" "web" {
#   ami           = "ami-0d3f444bc76de0a79"
#   instance_type = "t3.micro"

#   tags = {
#     Name = "MyInstance"
#   }
#   count = 10
# }

# data "aws_ami" "RHEL" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["RHEL-9.3.0_HVM-20231101-x86_64-5-Hourly2-GP2*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

# #   owners = ["099720109477"] # Canonical
# }

# resource "aws_instance" "web" {
#   ami           = data.aws_ami.RHEL.id
#   instance_type = "t3.micro"

#   tags = {
#     Name = "my-inst"
#   }
# }


resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "sub-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "my-sub-1"
  }
}

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = "t2.microg"
  subnet_id     = aws_subnet.sub-1.id

  cpu_options {
    core_count       = 2
    threads_per_core = 2
  }

  tags = {
    Name = "tf-example"
  }
  count = 2
}