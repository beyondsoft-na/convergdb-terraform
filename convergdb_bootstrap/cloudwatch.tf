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

resource "aws_cloudwatch_dashboard" "dashboard" {
  provider       = "aws"
  dashboard_name = "convergdb-${var.deployment_id}"

  dashboard_body = <<BODY
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 21,
            "height": 3,
            "properties": {
                "view": "singleValue",
                "stacked": false,
                "metrics": [
                    [ "convergdb/${var.deployment_id}", "batch_failure", { "stat": "Sum", "period": 86400 } ],
                    [ ".", "batch_success", { "stat": "Sum", "period": 86400 } ],
                    [ ".", "source_data_processed", { "period": 86400, "stat": "Sum" } ],
                    [ ".", "source_data_processed_uncompressed_estimate", { "period": 86400, "stat": "Sum" } ],
                    [ ".", "source_files_processed", { "period": 86400, "stat": "Sum" } ]
                ],
                "region": "${var.region}",
                "title": "Summary"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 3,
            "width": 21,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "convergdb/${var.deployment_id}", "source_data_processed", { "period": 21600, "stat": "Sum" } ],
                    [ ".", "source_data_processed_uncompressed_estimate", { "period": 21600, "stat": "Sum" } ]
                ],
                "region": "${var.region}",
                "title": "Data Volume"
            }
        }
    ]
}
BODY
}