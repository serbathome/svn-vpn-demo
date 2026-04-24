variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "appgw_subnet_id" {
  type = string
}

variable "svn_port" {
  type = number
}

variable "private_endpoint_ip" {
  type        = string
  description = "Private IP of the PE connecting to the Private Link Service."
}

variable "appgw_private_ip" {
  type        = string
  description = "Static private IP for the App Gateway frontend in snet-appgw."
}
