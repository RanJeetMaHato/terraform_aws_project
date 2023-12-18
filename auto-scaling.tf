
# resource "aws_instance" "web-1" {
#   ami           = var.ami_id
#   instance_type = var.instance_type
#   key_name      = var.ssh_key
#   subnet_id = aws_subnet.pub_1.id
#   user_data = <<EOF
#   #!/bin/bash
#   sudo apt-get update
#   sudo apt-get install apache2 -y
#   sudo systemctl start apache2
#    sudo systemctl enable apache2
#    EOF

# }

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "my_sg"

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
    Name = "my_sg"
  }

}




resource "aws_launch_template" "lt-1" {
  name_prefix   = "my_lt-1"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.ssh_key

}

resource "aws_autoscaling_group" "asg" {
 // availability_zones  = ["us-east-1a"]
  desired_capacity    = 3
  max_size            = 5
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.pvt_1.id, aws_subnet.pvt_2.id]

  launch_template {
    id      = aws_launch_template.lt-1.id
    version = "$Latest"
  }
}
resource "aws_autoscaling_policy" "asp" {
  name                   = "${var.name}-autoscaling"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "upper-threshold-alarm" {
  alarm_name                = "upper-threshold-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

  dimensions = {
    autoscaling_group_name = aws_autoscaling_group.asg.name
  }
  alarm_actions =[ aws_autoscaling_policy.asp.arn]
}

