# ConvergDB - DevOps for Data
# Copyright (C) 2018 Beyondsoft Consulting, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# unique identifier for this module
resource "random_id" "module_id" {
  byte_length = 8
}

provider "aws" {
  alias  = "myregion"
  region = "${var.region}"
}

# template file is used because there may be variables inside
# the stack definition which need to be resolved.
data "template_file" "stack" {
  template = "${file("${var.local_stack_file_path}")}"

  vars {
    admin_bucket = "${var.admin_bucket}"
    data_bucket = "${var.data_bucket}"
    deployment_id = "${var.deployment_id}"
    database_stack_id = "${var.database_stack_id}"
    aws_account_id = "${var.aws_account_id}"
  }
}

# stack file is pushed to S3 because it may be too large for inline use
resource "aws_s3_bucket_object" "stack" {
  bucket = "${var.admin_bucket}"
  key = "${var.s3_stack_key}"
  content = "${data.template_file.stack.rendered}"
  etag = "${md5("${data.template_file.stack.rendered}")}"
}

resource "aws_cloudformation_stack" "athena_relation_stack" {
  name          = "convergdb-${var.stack_name}-${var.deployment_id}"
  template_url = "https://s3.amazonaws.com/${var.admin_bucket}/${var.s3_stack_key}"
  provider      = "aws.myregion"

  tags {
    "convergdb:deployment" = "${var.deployment_id}"
    "convergdb:module"     = "${random_id.module_id.dec}"
  }
  depends_on = ["aws_s3_bucket_object.stack"]
}
