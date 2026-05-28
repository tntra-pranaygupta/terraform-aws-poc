output "vpc_id" { value = module.networking.vpc_id }
output "public_ip" { value = module.compute.public_ip }
output "website_url" { value = "http://${module.compute.public_ip}" }
output "alb_url" { value = "http://${module.alb.alb_dns_name}" }