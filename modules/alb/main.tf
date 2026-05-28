# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.alb_sg_id]
  tags               = { Name = "${var.project_name}-${var.environment}-alb" }
}
 
# Target Group — pool of EC2 instances the ALB routes to
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
 
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
}
 
# Listener — what ALB does when traffic arrives on port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
 
# Launch Template — blueprint for new EC2 instances
resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  user_data     = base64encode(file("${path.module}/../../scripts/user_data.sh"))
 
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.ec2_sg_id]
  }
 
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs { 
      volume_size = 30
      volume_type = "gp3"
      encrypted = true
      delete_on_termination = true 
    }
  }
 
  lifecycle { create_before_destroy = true }
 
  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project_name}-${var.environment}-asg-web" }
  }
}
 
# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                = "${var.project_name}-${var.environment}-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns   = [aws_lb_target_group.main.arn]
 
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
 
  health_check_type         = "ELB"
  health_check_grace_period = 300
 
  tag { 
    key = "Name"
    value = "${var.project_name}-${var.environment}-web"
    propagate_at_launch = true 
  }
}
 
# Scale UP policy when CPU > 70%
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}
 
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  dimensions          = { AutoScalingGroupName = aws_autoscaling_group.web.name }
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
}