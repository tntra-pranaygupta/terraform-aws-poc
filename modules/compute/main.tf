resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_pair_name
  vpc_security_group_ids = var.security_group_ids
  user_data              = file("${path.module}/../../scripts/docker_deploy.sh")
  user_data_replace_on_change = true
 
  root_block_device {
  volume_size           = 30
  volume_type           = "gp3"
  delete_on_termination = true
  encrypted             = true
}
 
  tags = { Name = "${var.project_name}-${var.environment}-web" }
}