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

variable "region" {}
variable "job_name" {}
variable "service_role" { default = "" }
variable "stack_name" {}
variable "local_script" {}
variable "local_pyspark_library" {}
variable "script_bucket" {}
variable "script_key" {}
variable "pyspark_library_key" {}
variable "schedule" {}
variable "dpu" {}
variable "deployment_id" {}
variable "admin_bucket" {}
variable "data_bucket" {}
variable "cloudwatch_namespace" {}
variable "sns_topic" {}
variable "convergdb_lock_table"
