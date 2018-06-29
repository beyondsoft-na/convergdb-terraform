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

# networking objects for vpc
resource "aws_vpc" "convergdb_vpc" {
  cidr_block = "${var.vpc_cidr}" ##
  tags {
    Name = "convergdb-${var.deployment_id}" ##
  }
}

resource "aws_subnet" "convergdb_public_subnet" {
  vpc_id = "${aws_vpc.convergdb_vpc.id}"  ##
  cidr_block = "${var.public_subnet_cidr}"
  tags {
    Name = "convergdb-${var.deployment_id}"
  }
}

resource "aws_internet_gateway" "convergdb_gw" {
  vpc_id = "${aws_vpc.convergdb_vpc.id}"
  tags {
    Name = "convergdb-${var.deployment_id}"
  }
}

resource "aws_route" "convergdb_route" {
  route_table_id         = "${aws_vpc.convergdb_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.convergdb_gw.id}"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${aws_vpc.convergdb_vpc.id}"
  service_name = "com.amazonaws.${var.region}.s3"
}
