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

# objects to be passed to the primary terraform deployment

resource "local_file" "main_backend" {
  content = <<EOF
{
  "terraform" : {
    "backend" : {
      "s3" : {
        "bucket" : "${var.admin_bucket}",
        "key" : "terraform/convergdb.tfstate",
        "dynamodb_table" : "${var.lock_table}",
        "region" : "${var.region}"
      }
    }
  }
}
EOF
  filename = "${var.backend_file_path}" # "${path.module}/../terraform/terraform.tf.json"
}

resource "local_file" "main_variables" {
  content = <<EOF
variable "deployment_id" {
  default = "${var.deployment_id}"
}

variable "region" {
  default = "${var.region}"
}

variable "admin_bucket" {
  default = "${var.admin_bucket}"
}

variable "data_bucket" {
  default = "${var.data_bucket}"
}

variable "fargate_cluster" {
  default = "${aws_ecs_cluster.convergdb_ecs_cluster.id}"
}

variable "fargate_vpc" {
  default = "${aws_vpc.convergdb_vpc.id}"
}

variable "fargate_subnet" {
  default = "${aws_subnet.convergdb_public_subnet.id}"
}

variable "ecs_log_group" {
  default = "${aws_cloudwatch_log_group.convergdb.name}"
}

variable "ecs_execution_role" {
  default = "${aws_iam_role.execution_task_role.id}"
}

EOF
  filename = "${var.variables_file_path}" #"${path.module}/../terraform/variables.tf"
}