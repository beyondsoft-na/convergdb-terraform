resource "aws_sns_topic" "convergdb-notifications" {
  name = "convergdb-${var.deployment_id}"
}
