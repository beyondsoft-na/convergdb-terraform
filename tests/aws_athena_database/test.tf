provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {}

variable "region" {
  default = "us-west-2"
}

variable "deployment_id" {
  default = "integrationtest"
}

module "convergdb_athena_databases_stack" {
  source  = "github.com/beyondsoft-na/convergdb-terraform//aws_athena_database?ref=611e8539bc7e27699a5bb7cdd6921a1185d8b0a9"
  region  = "${var.region}"
  stack   = "{\"AWSTemplateFormatVersion\":\"2010-09-09\",\"Description\":\"Create ConvergDB databases in Glue catalog\",\"Resources\":{\"integrationtestdatabase${var.deployment_id}\":{\"Type\":\"AWS::Glue::Database\",\"Properties\":{\"CatalogId\":\"${data.aws_caller_identity.current.account_id}\",\"DatabaseInput\":{\"Name\":\"integration_test_database${var.deployment_id}\",\"Parameters\":{\"convergdb_deployment_id\":\"${var.deployment_id}\"}}}}}}",
  deployment_id = "${var.deployment_id}"
}
