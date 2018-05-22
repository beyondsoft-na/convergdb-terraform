variable "region" {}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "deployment_id" {}
variable "admin_bucket" {}
variable "data_bucket" {}
variable "lock_table" {}
variable "backend_file_path" {}
variable "variables_file_path" {}