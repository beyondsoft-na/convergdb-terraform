data "template_file" "fargate_lambda_trigger" {
  template = "${file("${path.module}/lambda_template.py.tpl")}"

  vars {
    cluster_name  = "${var.ecs_cluster}"
    task_arn      = "${aws_ecs_task_definition.convergdb_ecs_task.arn}"
    task_role_arn = "${aws_iam_role.ecs_task_role.arn}"
    subnet        = "${var.ecs_subnet}"
    memory        = "${var.fargate_memory}"
    cpu           = "${var.fargate_cpu}"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "run_task" {
  name = "convergdb-${var.deployment_id}-${var.etl_job_name}-lambda-run-task"
  role = "${aws_iam_role.iam_for_lambda.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "glue:RunTask"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket_object" "fargate_lambda_trigger_script" {
  bucket = "${var.admin_bucket}"
  key    = "${var.lambda_trigger_key}"
  content = "${data.template_file.fargate_lambda_trigger.rendered}"
}

resource "aws_lambda_function" "test_lambda" {
  s3_bucket        = "${var.admin_bucket}"
  s3_key           = "${aws_s3_bucket_object.fargate_lambda_trigger_script.id}"
  function_name    = "convergdb-${var.deployment_id}-${var.etl_job_name}-trigger"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  source_code_hash = "${base64sha256(file("${data.template_file.fargate_lambda_trigger.rendered}"))}"
  handler          = "handler"
  runtime          = "python2.7"
}