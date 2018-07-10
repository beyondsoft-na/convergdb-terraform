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

resource "aws_cloudformation_stack" "athena_database_stack" {
  name          = "convergdb-tf-db-${var.deployment_id}-${random_id.module_id.dec}"
  template_body = "${var.stack}"

  tags {
    "convergdb:deployment" = "${var.deployment_id}"
    "convergdb:module"     = "${random_id.module_id.dec}"
  }
}

output "database_stack_id" {
  value = "${aws_cloudformation_stack.athena_database_stack.id}"
}
