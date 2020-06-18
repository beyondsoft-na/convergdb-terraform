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

resource "aws_s3_bucket_object" "convergdb_library" {
  bucket = var.script_bucket
  key    = var.pyspark_library_key
  source = var.local_pyspark_library
  etag   = filemd5(var.local_pyspark_library)

  tags = {
    "convergdb:deployment" = var.deployment_id
  }
}

resource "aws_s3_bucket_object" "script_object" {
  bucket  = var.script_bucket
  key     = var.script_key
  content = local.script_object_source
  etag    = md5(local.script_object_source)

  tags = {
    "convergdb:deployment" = var.deployment_id
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "convergdb-${var.deployment_id}-${var.etl_job_name}-task-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "s3_access" {
  name = "convergdb-${var.deployment_id}-${var.etl_job_name}-access-policy"
  role = aws_iam_role.ecs_task_role.name

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
        "s3:ListBucketMultipartUploads",
        "s3:GetEncryptionConfiguration"
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
        "glue:*"
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
            "${var.etl_job_name}"
          ]
        }
      }
    }
  ]
}
EOF

}

resource "aws_ecs_task_definition" "convergdb_ecs_task" {
  family                   = "convergdb-${var.deployment_id}-${var.etl_job_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = var.execution_task_role

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "image": "${var.docker_image}",
    "name": "convergdb",
    "networkMode": "awsvpc",
    "environment": [
      {
        "name": "CONVERGDB_LIBRARY",
        "value": "s3://${var.script_bucket}/${var.pyspark_library_key}"
      },
      {
        "name": "CONVERGDB_SCRIPT",
        "value": "s3://${var.script_bucket}/${var.script_key}"
      },
      {
        "name": "LOCK_TABLE",
        "value": "${var.etl_lock_table}"
      },
      {
        "name": "LOCK_ID",
        "value": "${var.etl_job_name}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${var.ecs_log_group}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "${var.etl_job_name}"
      }
    },
    "portMappings": []
  }
]
DEFINITION

}

resource "aws_iam_role" "ecs_events" {
  name = "cdb-${var.deployment_id}-${var.etl_job_name}-event-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_events_policy" {
  role = aws_iam_role.ecs_events.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": [
            "ecs:*",
            "iam:PassRole"
        ],
        "Effect": "Allow",
        "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_cloudwatch_event_rule" "convergdb_etl" {
  name                = "convergdb-${var.deployment_id}-${var.etl_job_name}-trigger"
  description         = "convergdb etl job ${var.etl_job_name}"
  schedule_expression = var.etl_job_schedule
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "ecs_task" {
  rule      = aws_cloudwatch_event_rule.convergdb_etl.name
  target_id = "convergdb-${var.deployment_id}-${var.etl_job_name}-target"
  arn       = var.ecs_cluster
  role_arn  = aws_iam_role.ecs_events.arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.convergdb_ecs_task.arn
    task_count          = 1
    launch_type         = "FARGATE"
    platform_version    = "LATEST"

    network_configuration {
      subnets = [var.ecs_subnet]
    }
  }
}

