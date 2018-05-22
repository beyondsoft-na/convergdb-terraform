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

provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_object" "convergdb_library" {
  bucket   = "${var.script_bucket}"
  key      = "${var.pyspark_library_key}"
  source   = "${var.local_pyspark_library}"
  etag     = "${md5(file("${var.local_pyspark_library}"))}"

  tags {
    "convergdb:deployment" = "${var.deployment_id}"
  }
}

data "template_file" "script_object_source" {
  template = "${file("${var.local_script}")}"

  vars {
    admin_bucket = "${var.admin_bucket}"
    data_bucket = "${var.data_bucket}"
    deployment_id = "${var.deployment_id}"
    region = "${var.region}"
    sns_topic = "${var.sns_topic}"
    cloudwatch_namespace = "${var.cloudwatch_namespace}"
  }
}

resource "aws_s3_bucket_object" "script_object" {
  bucket   = "${var.script_bucket}"
  key      = "${var.script_key}"
  content  = "${data.template_file.script_object_source.rendered}"
  etag     = "${md5("${data.template_file.script_object_source.rendered}")}"

  tags {
    "convergdb:deployment" = "${var.deployment_id}"
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "convergdb-${var.deployment_id}-${var.etl_job_name}-task-role"
  path = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_assume_role_policy.json}"
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
  role = "${aws_iam_role.ecs_task_role.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "athena:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:sns:::convergdb*"
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
        "glue:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_ecs_task_definition" "convergdb_ecs_task" {
  family = "convergdb-${var.deployment_id}-${var.etl_job_name}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "${var.fargate_cpu}"
  memory = "${var.fargate_memory}"
  task_role_arn = "${aws_iam_role.ecs_task_role.arn}"
  execution_role_arn = "${var.execution_task_role}"
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
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${var.ecs_log_group}",
        "awslogs-region": "us-west-2",
        "awslogs-stream-prefix": "${var.etl_job_name}"
      }
    }
  }
]
DEFINITION
}

resource "aws_cloudwatch_event_rule" "convergdb_etl" {
  name        = "convergdb-${var.deployment_id}-${var.etl_job_name}-trigger"
  description = "convergdb etl job ${var.etl_job_name}"
  schedule_expression = "${var.etl_job_schedule}"
}

resource "aws_cloudwatch_event_target" "ecs_task" {
  rule      = "${aws_cloudwatch_event_rule.convergdb_etl.name}"
  target_id = "convergdb-${var.deployment_id}-${var.etl_job_name}-target"
  arn = "${var.ecs_cluster}"
  role_arn = "${aws_iam_role.ecs_task_role.arn}"
  ecs_target {
    task_definition_arn = "${aws_ecs_task_definition.convergdb_ecs_task.arn}"
    task_count = 1
  }
}
