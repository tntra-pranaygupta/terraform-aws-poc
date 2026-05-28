#!/bin/bash
set -e
exec > >(tee /var/log/user_data.log|logger -t user-data -s 2>/dev/console) 2>&1
 
echo "=== Starting setup at $(date) ==="
 
# Update all packages
dnf update -y
 
# Install Nginx
dnf install -y nginx
 
# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
 
# Create custom HTML page
cat > /usr/share/nginx/html/index.html <<HTML
<!DOCTYPE html>
<html>
<head><title>Terraform POC</title>
<style>
body{font-family:Arial;background:#1a1a2e;color:#eee;text-align:center;padding:50px}
.card{background:#16213e;border-radius:10px;padding:40px;max-width:600px;margin:auto}
h1{color:#e94560}.tag{background:#0f3460;padding:5px 15px;border-radius:20px;
display:inline-block;margin:5px}
</style></head>
<body><div class="card">
<h1>Terraform POC Deployed!</h1>
<p>Infrastructure provisioned by Terraform</p>
<div class="tag">Instance: $INSTANCE_ID</div>
<div class="tag">IP: $PUBLIC_IP</div>
<div class="tag">AZ: $AZ</div>
</div></body></html>
HTML
 
# Enable Nginx to auto-start on reboot
systemctl enable nginx
 
# Start Nginx right now
systemctl start nginx
 
echo "=== Setup complete at $(date) ==="