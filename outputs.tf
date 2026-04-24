output "vpn_gateway_public_ip" {
  description = "Public IP of the VPN Gateway for P2S client configuration."
  value       = module.vpn_gateway.vpn_public_ip
}

output "app_gateway_private_ip" {
  description = "Private IP of the Application Gateway (reachable via VPN)."
  value       = module.app_gateway.app_gateway_private_ip
}

output "svn_vm_private_ip" {
  description = "Private IP of the SVN server VM."
  value       = module.svn_server.vm_private_ip
}

output "private_endpoint_ip" {
  description = "Private IP of the endpoint connecting to the SVN Private Link Service."
  value       = module.private_endpoint.private_endpoint_ip
}
