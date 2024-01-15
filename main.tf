resource "aws_instance" "web" {
  ami           = "ami-0d3f444bc76de0a79"
  instance_type = "t3.micro"

  tags = {
    Name = "MyInstance"
  }
  count = 10
}