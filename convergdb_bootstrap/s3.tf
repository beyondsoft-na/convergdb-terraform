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

# s3 buckets
resource "aws_s3_bucket" "admin" {
  bucket = var.admin_bucket

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.sse_encryption_algorithm
      }
    }
  }

  lifecycle_rule {
    id      = "athena_tmp_results_expiration"
    prefix  = "${var.deployment_id}/tmp/"
    enabled = true

    expiration {
      days = 3
    }
  }
}

resource "aws_s3_bucket" "data" {
  bucket = var.data_bucket

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.sse_encryption_algorithm
      }
    }
  }

  lifecycle_rule {
    id      = "convergdb_data_version_expiration"
    enabled = true

    noncurrent_version_expiration {
      days = 7
    }
  }
}

