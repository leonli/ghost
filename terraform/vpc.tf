# Create a VPC to launch our instances into
resource "aws_vpc" "apps" {
  cidr_block = "${lookup(var.vpc_cidr_prefix, var.region)}.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "apps_igw" {
  vpc_id = "${aws_vpc.apps.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.apps.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.apps_igw.id}"
}

# Create 3 subnets within the VPC for the availability_zone
resource "aws_subnet" "apps_public_subnet" {
  # We will create the definied length of the vailability zone for each subnet
  count                   = "${length(split(",", lookup(var.azs, var.region)))}"
  vpc_id                  = "${aws_vpc.apps.id}"
  cidr_block              = "${lookup(var.vpc_cidr_prefix, var.region)}.${count.index + 1}.0/24"
  availability_zone       = "${element(split(",", lookup(var.azs, var.region)), count.index)}"
  map_public_ip_on_launch = true
}
