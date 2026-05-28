#!/bin/bash
set -e
exec > >(tee /var/log/docker_deploy.log|logger -t docker -s 2>/dev/console) 2>&1
 
echo "=== Docker setup starting at $(date) ==="
 
# Update system packages
dnf update -y
 
# Install Docker
dnf install -y docker
 
# Start Docker and enable on reboot
systemctl enable docker
systemctl start docker
 
# Add ec2-user to docker group (avoids needing sudo for docker commands)
usermod -aG docker ec2-user
 
# Pull and run a containerized Nginx
docker run \
  --detach \
  --name webapp \
  --publish 80:80 \
  --restart always \
  nginx:alpine
 
# Verify container started
sleep 5
docker ps | grep webapp && echo "Container is running!" || echo "ERROR: container failed"
 
echo "=== Docker setup complete at $(date) ==="