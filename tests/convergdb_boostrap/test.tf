variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "deployment_id" {
  default = "integtest-deployment-id"
}

variable "admin_bucket" {
  default = "integration-test-convergdb-bootstrap-admin-bucket"
}

variable "data_bucket" {
  default = "integration-test-convergdb-bootstrap-data-bucket"
}

variable "lock_table" {
  default = "integration-test-convergdb-bootstrap-lock-table"
}

variable "backend_file_path" {
  default = "integration-test-convergdb-bootstrap-backend-file-path"
}

variable "variables_file_path" {
  default = "integration-test-convergdb-bootstrap-variables-file-path"
}

module "convergdb_bootstrap_integration_test" {
  source              = "github.com/beyondsoft-na/convergdb-terraform//convergdb_bootstrap?ref=5fbaccc903c06968cf24423af4e760c9f54614bc"
  region              = "${var.region}"
  vpc_cidr            = "${var.vpc_cidr}"
  public_subnet_cidr  = "${var.public_subnet_cidr}"
  deployment_id       = "${var.deployment_id}"
  admin_bucket        = "${var.admin_bucket}"
  data_bucket         = "${var.data_bucket}"
  lock_table          = "${var.lock_table}"
  backend_file_path   = "${var.backend_file_path}"
  variables_file_path = "${var.variables_file_path}"
}
