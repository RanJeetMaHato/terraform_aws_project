output "dns_lb" {
    description = "DNS of loadbalancer"
    value = aws_lb.alb.dns_name
  
}

output "public-ip" {
    value = data.aws_instance.demo.public_ip
  
}