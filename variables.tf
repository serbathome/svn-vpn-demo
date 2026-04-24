variable "subscription_id" {
  type        = string
  description = "The subscription ID for the Azure resources."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
  default     = "svn-demo"
}

variable "location" {
  type        = string
  description = "Azure region for all resources."
  default     = "germanywestcentral"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources."
  default = {
    environment = "demo"
    workload    = "svn-server-vpn"
    managed-by  = "terraform"
  }
}

# ── Networking ──────────────────────────────────────────────

variable "dmz_vnet_address_space" {
  type        = string
  description = "Address space for the DMZ VNet."
  default     = "10.1.0.0/16"
}

variable "bmw_vnet_address_space" {
  type        = string
  description = "Address space for the BMW VNet."
  default     = "10.2.0.0/16"
}

variable "gateway_subnet_prefix" {
  type        = string
  description = "CIDR for GatewaySubnet in DMZ VNet."
  default     = "10.1.0.0/27"
}

variable "appgw_subnet_prefix" {
  type        = string
  description = "CIDR for Application Gateway subnet in DMZ VNet."
  default     = "10.1.1.0/24"
}

variable "pe_subnet_prefix" {
  type        = string
  description = "CIDR for Private Endpoint subnet in DMZ VNet."
  default     = "10.1.2.0/24"
}

variable "pls_subnet_prefix" {
  type        = string
  description = "CIDR for Private Link Service subnet in BMW VNet."
  default     = "10.2.0.0/24"
}

variable "svn_subnet_prefix" {
  type        = string
  description = "CIDR for SVN server subnet in BMW VNet."
  default     = "10.2.1.0/24"
}

# ── VPN Gateway ─────────────────────────────────────────────

variable "vpn_client_address_pool" {
  type        = string
  description = "Address pool for P2S VPN clients."
  default     = "172.16.0.0/24"
}

variable "aad_tenant_id" {
  type        = string
  description = "Entra ID (AAD) tenant ID for VPN authentication."
}

variable "aad_audience" {
  type        = string
  description = "Entra ID audience (application ID) for VPN authentication. Use the Azure VPN Enterprise App ID for your cloud."
  default     = "c632b3df-fb67-4d84-bdcf-b95ad541b5c8"
}

# ── SVN Server VM ───────────────────────────────────────────

variable "vm_admin_username" {
  type        = string
  description = "Admin username for the SVN server VM."
  default     = "svnadmin"
}

variable "vm_admin_password" {
  type        = string
  description = "Admin password for the SVN server VM."
  sensitive   = true
}

variable "vm_size" {
  type        = string
  description = "VM size for the SVN server."
  default     = "Standard_B2s"
}

variable "svn_port" {
  type        = number
  description = "Port the SVN service listens on (443 for VisualSVN / HTTPS)."
  default     = 443
}