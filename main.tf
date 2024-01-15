# resource "aws_instance" "web" {
#   ami           = "ami-0d3f444bc76de0a79"
#   instance_type = "t3.micro"

#   tags = {
#     Name = "MyInstance"
#   }
#   count = 10
# }

data "aws_ami" "RHEL" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-9.3.0_HVM-20231101-x86_64-5-Hourly2-GP2*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

#   owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "my-inst"
  }
}