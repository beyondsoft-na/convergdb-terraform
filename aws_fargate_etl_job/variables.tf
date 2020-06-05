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

variable "region" {
}

variable "deployment_id" {
}

variable "etl_job_name" {
}

variable "etl_job_schedule" {
}

variable "etl_lock_table" {
}

variable "local_script" {
}

variable "local_pyspark_library" {
}

variable "script_bucket" {
}

variable "script_key" {
}

variable "pyspark_library_key" {
}

variable "lambda_trigger_key" {
}

variable "admin_bucket" {
}

variable "data_bucket" {
}

variable "cloudwatch_namespace" {
}

variable "sns_topic" {
}

variable "ecs_subnet" {
}

variable "ecs_cluster" {
}

variable "ecs_log_group" {
}

variable "docker_image" {
}

variable "execution_task_role" {
}

variable "fargate_cpu" {
  default = 1024
}

variable "fargate_memory" {
  default = 4096
}
