variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "dmz_vnet_address_space" {
  type = string
}

variable "bmw_vnet_address_space" {
  type = string
}

variable "gateway_subnet_prefix" {
  type = string
}

variable "appgw_subnet_prefix" {
  type = string
}

variable "pe_subnet_prefix" {
  type = string
}

variable "pls_subnet_prefix" {
  type = string
}

variable "svn_subnet_prefix" {
  type = string
}

variable "svn_port" {
  type = number
}
