# Define the security group for db instance
resource "aws_security_group" "ghost_db_sg" {
  depends_on = ["aws_security_group.ghost_instances_sg"]

  name        = "ghost_rds_sg"
  description = "Ghost RDS Security Group"
  vpc_id      = "${aws_vpc.apps.id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ghost_instances_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "ghost_db_subnet" {
  count             = 2
  vpc_id            = "${aws_vpc.apps.id}"
  cidr_block        = "${lookup(var.vpc_cidr_prefix, var.region)}.8${count.index + 1}.0/24"
  availability_zone = "${element(split(",", lookup(var.azs, var.region)), count.index)}"
}

# Define RDS db instance
resource "aws_db_instance" "ghost_rds" {
  depends_on             = ["aws_security_group.ghost_db_sg"]
  identifier             = "${var.identifier}"
  allocated_storage      = "${var.storage}"
  engine                 = "${var.engine}"
  engine_version         = "${lookup(var.engine_version, var.engine)}"
  instance_class         = "${var.instance_class}"
  name                   = "${var.db_name}"
  username               = "${var.db_username}"
  password               = "${var.db_password}"
  vpc_security_group_ids = ["${aws_security_group.ghost_db_sg.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.rds_subnet_group.id}"
  multi_az               = true

}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "ghost_rds_subnet_group"
  description = "Our RDS group of subnets"
  subnet_ids  = ["${aws_subnet.ghost_db_subnet.*.id}"]
}
