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

resource "aws_glue_catalog_table" "table" {
  name          = "${var.table_name}"
  database_name = "${var.database_name}"
  table_type    = "${var.table_type}"

  storage_descriptor {
    columns                   = "${var.columns}"
    location                  = "${var.location}"
    input_format              = "${var.input_format}"
    output_format             = "${var.output_format}"
    compressed                = "${var.compressed}"
    number_of_buckets         = "${var.number_of_buckets}"
    
    ser_de_info {
  		name                  = "${var.ser_de_info_name}"
			serialization_library = "${var.ser_de_info_serialization_library}" 
			parameters {
				"serialization.format" = "1"
			}
		}
		
    bucket_columns            = "${var.bucket_columns}"
    sort_columns              = "${var.sort_columns}"
#    skewed_info {
#      skewed_column_names               = "${var.skewed_column_names}"
#      skewed_column_value_location_maps = "${var.skewed_column_value_location_maps}"
#      skewed_column_values              = "${var.skewed_column_values}"
#    }
    stored_as_sub_directories = "${var.stored_as_sub_directories}"
  }
  
  partition_keys = "${var.partition_keys}"
  
  parameters {
    classification               = "${var.classification}"
    EXTERNAL                     = "TRUE"
    convergdb_full_relation_name = "${var.convergdb_full_relation_name}"
    convergdb_dsd                = "${var.convergdb_dsd}"
    convergdb_storage_bucket     = "${var.convergdb_storage_bucket}"
    convergdb_state_bucket       = "${var.convergdb_state_bucket}"
    convergdb_storage_format     = "${var.convergdb_storage_format}"
    convergdb_etl_job_name       = "${var.convergdb_etl_job_name}"
    convergdb_deployment_id      = "${var.convergdb_deployment_id}"
  }
}
