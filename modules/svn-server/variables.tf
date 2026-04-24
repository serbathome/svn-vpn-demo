variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "subscription_id" {
  type = string
}

variable "svn_subnet_id" {
  type = string
}

variable "pls_subnet_id" {
  type = string
}

variable "vm_admin_username" {
  type = string
}

variable "vm_admin_password" {
  type      = string
  sensitive = true
}

variable "vm_size" {
  type = string
}

variable "svn_port" {
  type = number
}
