variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "gateway_subnet_id" {
  type = string
}

variable "vpn_client_address_pool" {
  type = string
}

variable "aad_tenant_id" {
  type = string
}

variable "aad_audience" {
  type = string
}
