data "aws_instance" "demo" {
    filter {
     name = "tag:Name" 
     values = ["data"]
    }
  
}