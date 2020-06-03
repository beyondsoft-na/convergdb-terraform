import os
import sys
from awsglue.utils import getResolvedOptions
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'convergdb_lock_table','aws_region'])
os.environ['AWS_GLUE_REGION'] = args['aws_region']
os.environ['LOCK_TABLE'] = args['convergdb_lock_table']
os.environ['LOCK_ID']    = args['JOB_NAME']
import convergdb
from convergdb.glue_header import *

convergdb.source_to_target(
  sql_context(),
"""
{
  "generators": [
    "athena",
    "glue",
    "fargate",
    "markdown_doc",
    "html_doc",
    "control_table"
  ],
  "full_relation_name": "prod.ecommerce.inventory.books",
  "dsd": "ecommerce.inventory.books",
  "environment": "prod",
  "domain_name": null,
  "schema_name": null,
  "relation_name": null,
  "service_role": null,
  "script_bucket": "${admin_bucket}",
  "temp_s3_location": null,
  "storage_bucket": "${data_bucket}/${deployment_id}/prod.ecommerce.inventory.books",
  "state_bucket": "${admin_bucket}",
  "storage_format": "parquet",
  "source_relation_prefix": null,
  "inventory_source": "default",
  "use_inventory": "false",
  "etl_job_name": "demo2",
  "etl_job_schedule": "cron(0 7 * * ? *)",
  "etl_job_dpu": 2,
  "etl_technology": "aws_glue",
  "etl_docker_image": null,
  "etl_docker_image_digest": null,
  "spark_partition_count": 2,
  "attributes": [
    {
      "name": "item_number",
      "required": false,
      "expression": "item_number",
      "data_type": "integer",
      "field_type": null,
      "cast_type": "integer"
    },
    {
      "name": "title",
      "required": false,
      "expression": "title",
      "data_type": "varchar(100)",
      "field_type": null,
      "cast_type": "string"
    },
    {
      "name": "author",
      "required": false,
      "expression": "author",
      "data_type": "varchar(100)",
      "field_type": null,
      "cast_type": "string"
    },
    {
      "name": "price",
      "required": false,
      "expression": "price",
      "data_type": "numeric(10,2)",
      "field_type": null,
      "cast_type": "decimal(10,2)"
    },
    {
      "name": "part_id",
      "required": false,
      "expression": "substring(md5(title),1,1)",
      "data_type": "varchar(100)",
      "field_type": null,
      "cast_type": "string"
    },
    {
      "name": "retail_markup",
      "required": false,
      "expression": "price * 0.26",
      "data_type": "numeric(10,2)",
      "field_type": null,
      "cast_type": "decimal(10,2)"
    },
    {
      "name": "source_file",
      "required": false,
      "expression": "convergdb_source_file_name",
      "data_type": "varchar(100)",
      "field_type": null,
      "cast_type": "string"
    }
  ],
  "partitions": [
    "part_id"
  ],
  "relation_type": 1,
  "source_dsd_name": "ecommerce.inventory.books_source",
  "full_source_relation_name": "prod.ecommerce.inventory.books_source",
  "source_structure": {
    "generators": [
      "streaming_inventory",
      "s3_source",
      "markdown_doc",
      "html_doc"
    ],
    "dsd": "ecommerce.inventory.books_source",
    "full_relation_name": "prod.ecommerce.inventory.books_source",
    "environment": "prod",
    "domain_name": null,
    "schema_name": null,
    "relation_name": null,
    "storage_bucket": "demo-source-us-west-2.beyondsoft.us",
    "storage_format": "json",
    "inventory_table": "",
    "streaming_inventory": "false",
    "streaming_inventory_output_bucket": null,
    "streaming_inventory_table": null,
    "csv_header": null,
    "csv_separator": null,
    "csv_quote": null,
    "csv_null": null,
    "csv_escape": null,
    "csv_trim": null,
    "attributes": [
      {
        "name": "item_number",
        "required": false,
        "expression": null,
        "data_type": "integer",
        "field_type": null,
        "cast_type": "integer"
      },
      {
        "name": "title",
        "required": false,
        "expression": null,
        "data_type": "varchar(100)",
        "field_type": null,
        "cast_type": "string"
      },
      {
        "name": "author",
        "required": false,
        "expression": null,
        "data_type": "varchar(100)",
        "field_type": null,
        "cast_type": "string"
      },
      {
        "name": "price",
        "required": false,
        "expression": null,
        "data_type": "numeric(10,2)",
        "field_type": null,
        "cast_type": "decimal(10,2)"
      },
      {
        "name": "stock",
        "required": false,
        "expression": null,
        "data_type": "integer",
        "field_type": null,
        "cast_type": "integer"
      }
    ],
    "partitions": [

    ],
    "relation_type": 0,
    "source_dsd_name": null,
    "working_path": "/Users/ruipan/Projects/CovergDB/Demo"
  },
  "control_table": "convergdb_control_${deployment_id}.prod__ecommerce__inventory__books",
  "working_path": "/Users/ruipan/Projects/CovergDB/Demo",
  "deployment_id": "${deployment_id}",
  "region": "${region}",
  "sns_topic": "${sns_topic}",
  "cloudwatch_namespace": "${cloudwatch_namespace}"
}
"""
)

