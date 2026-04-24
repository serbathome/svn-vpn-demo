variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "pe_subnet_id" {
  type = string
}

variable "private_link_service_id" {
  type = string
}
