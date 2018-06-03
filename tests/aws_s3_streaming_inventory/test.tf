provider "aws" {
  region = "${var.region}"
}

variable "region" {
  default = "us-west-2"
}

# source bucket
variable "source_bucket" {
  default = "s3-streaming-inventory-integration-test-source-bucket"
}

# destination bucket for firehose
variable "destination_bucket" {
  default = "s3-streaming-inventory-integration-test-destination-bucket"
}

# prefix for writing output files
variable "destination_prefix" {
  default = "s3-streaming-inventory-integration-test-destination-prefix/"
}

# kinesis firehose stream name
variable "firehose_stream_name" {
  default = "s3-streaming-inventory-integration-test-firehose-stream-name"
}

# provide lambda name
variable "lambda_name" {
  default = "s3-streaming-inventory-integration-test-lambda-name"
}

# create source bucket
resource "aws_s3_bucket" "integration_test_source_bucket" {
  bucket = "${var.source_bucket}"
}

# create destination bucket
resource "aws_s3_bucket" "integration_test_destination_bucket" {
  bucket = "${var.destination_bucket}"
}

module "s3_streaming_inventory_integration_test" {
  source  = "github.com/beyondsoft-na/convergdb-terraform//aws_s3_streaming_inventory?ref=611e8539bc7e27699a5bb7cdd6921a1185d8b0a9"
  region  = "${var.region}"
  source_bucket = "${aws_s3_bucket.integration_test_source_bucket.bucket}"
  destination_bucket = "${aws_s3_bucket.integration_test_destination_bucket.bucket}"
  destination_prefix = "${var.destination_prefix}"
  firehose_stream_name = "${var.firehose_stream_name}"
  lambda_name = "${var.lambda_name}"
}
