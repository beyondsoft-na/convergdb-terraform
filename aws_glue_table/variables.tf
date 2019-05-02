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

variable "database_name" {}

variable "table_name" {}

variable "table_type" {
  default = "EXTERNAL_TABLE"
}

#
# storage_descriptor items
#

variable "columns" {
  type = "map"
}

variable "location" {} # (Optional) The physical location of the table. By default this takes the form of the warehouse location, followed by the database location in the warehouse, followed by the table name.
variable "input_format" {} # (Optional) The input format: SequenceFileInputFormat (binary), or TextInputFormat, or a custom format.
variable "output_format" {} # (Optional) The output format: SequenceFileOutputFormat (binary), or IgnoreKeyTextOutputFormat, or a custom format.
variable "compressed" {} # (Optional) True if the data in the table is compressed, or False if not.
variable "number_of_buckets" {} # (Optional) Must be specified if the table contains any dimension columns.
variable "ser_de_info_name" {}
variable "ser_de_info_serialization_library" {}

variable "bucket_columns" {
  type = "list"
  default = []
} # (Optional) A list of reducer grouping columns, clustering columns, and bucketing columns in the table.

variable "sort_columns" {
  type    = "list"
  default = []
} # (Optional) A list of Order objects specifying the sort order of each bucket in the table.

# skewed info
variable "skewed_column_names" {
  type = "list"
  default = []
}

variable "skewed_column_value_location_maps" {
  type = "map"
} 

variable "skewed_column_values" {
  type = "list"
  default = []
} 

variable "stored_as_sub_directories" {} # (Optional) True if the table data is stored in subdirectories, or False if not.

#
# partition keys
#

variable "partition_keys" {}

#
# parameters (table properties)
#

variable "classification" {}
variable "convergdb_full_relation_name" {}
variable "convergdb_dsd" {}
variable "convergdb_storage_bucket" {}
variable "convergdb_state_bucket" {}
variable "convergdb_storage_format" {}
variable "convergdb_etl_job_name" {}
variable "convergdb_deployment_id" {}
