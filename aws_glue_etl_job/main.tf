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

locals {
  script_object_source = templatefile(("${var.local_script}"), {
      admin_bucket         = var.admin_bucket
      data_bucket          = var.data_bucket
      deployment_id        = var.deployment_id
      region               = var.region
      sns_topic            = var.sns_topic
      cloudwatch_namespace = var.cloudwatch_namespace
    }
  )
}

data "aws_caller_identity" "current" {
}

# unique identifier for this module
resource "random_id" "module_id" {
  byte_length = 8
}

output "module_id" {
  value = random_id.module_id.dec
}

resource "aws_cloudformation_stack" "glue_etl_stack" {
  name = "${var.stack_name}-${random_id.module_id.dec}"

  template_body = <<STACK
AWSTemplateFormatVersion: "2010-09-09"
Description: Glue ETL Job and Schedule

Resources:

  GlueJob:
    Type: "AWS::Glue::Job"
    Properties:
      Name: "${var.job_name}"
      Role: ${coalesce(var.service_role, aws_iam_role.glue_service_role.name)}
      DefaultArguments:
        "--extra-py-files": "s3://${var.script_bucket}/${var.pyspark_library_key}"
        "--convergdb_deployment_id": ${var.deployment_id}
        "--conf": "spark.yarn.executor.memoryOverhead=1024"
        "--convergdb_lock_table": "${var.etl_lock_table}"
        "--convergdb_job_name": "${var.job_name}"
        "--aws_region": "${var.region}"
      Command:
        Name: glueetl
        ScriptLocation: "s3://${var.script_bucket}/${var.script_key}"
      MaxCapacity: ${var.dpu}

  ScheduledGlueTrigger:
    Type: "AWS::Glue::Trigger"
    Properties:
      Type: SCHEDULED
      Name: "convergdb-${var.job_name}"
      Schedule: "${var.schedule}"
      Actions:
        - JobName: !Ref GlueJob
STACK


  depends_on = [
    aws_s3_bucket_object.script_object,
    aws_s3_bucket_object.library_object,
    aws_iam_role_policy_attachment.attach_glue_service,
    aws_iam_role_policy.s3_access,
  ]

  tags = {
    "convergdb:deployment" = var.deployment_id
    "convergdb:module"     = random_id.module_id.dec
  }
}

resource "aws_iam_role" "glue_service_role" {
  name = "convergdb-${var.job_name}-${random_id.module_id.dec}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "attach_glue_service" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "s3_access" {
  name = "convergdb-${var.job_name}-s3-access-policy-${random_id.module_id.dec}"
  role = aws_iam_role.glue_service_role.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:CreateBucket",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:ListMultipartUploadParts",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:s3:::convergdb-admin-${var.deployment_id}/${var.deployment_id}",
          "arn:aws:s3:::convergdb-admin-${var.deployment_id}/${var.deployment_id}/*",
          "arn:aws:s3:::convergdb-data-${var.deployment_id}/${var.deployment_id}",
          "arn:aws:s3:::convergdb-data-${var.deployment_id}/${var.deployment_id}/*"
      ]
    },
    {
      "Action": [
        "athena:StartQueryExecution",
        "athena:GetQueryExecution",
        "athena:GetQueryResults"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:sns:::convergdb-${var.deployment_id}"
    },
    {
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "dynamodb:DeleteItem",
        "dynamodb:PutItem"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.etl_lock_table}",
      "Condition": {
        "ForAllValues:StringEquals": {
          "dynamodb:LeadingKeys": [
            "${var.job_name}"
          ]
        }
      }
    }
  ]
}
EOF

}

resource "aws_s3_bucket_object" "script_object" {
  bucket  = var.script_bucket
  key     = var.script_key
  content = local.script_object_source
  etag    = md5(local.script_object_source)

  tags = {
    "convergdb:deployment" = var.deployment_id
    "convergdb:module"     = random_id.module_id.dec
  }
}

resource "aws_s3_bucket_object" "library_object" {
  bucket = var.script_bucket
  key    = var.pyspark_library_key
  source = var.local_pyspark_library
  etag   = filemd5(var.local_pyspark_library)

  tags = {
    "convergdb:deployment" = var.deployment_id
    "convergdb:module"     = random_id.module_id.dec
  }
}
