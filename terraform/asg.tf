## Define the ELB security group first 
resource "aws_security_group" "ghost_elb_sg" {
  name        = "ghost_elb_sg"
  description = "The security gourp defined for ELB"
  vpc_id = "${aws_vpc.apps.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define the ghost instance security group 
resource "aws_security_group" "ghost_instances_sg" {
  name        = "ghost_instances_sg"
  description = "The security gourp defined for the ghost running instances"
  vpc_id = "${aws_vpc.apps.id}"
  # depends_on  = ["${aws_security_group.ghost_elb_sg}"]

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from ELB security group
  ingress {
    from_port       = 2368
    to_port         = 2368
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ghost_elb_sg.id}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ELB for the ghost app
resource "aws_elb" "ghost_elb" {
  name = "ghost-elb"

  # The same availability zone as our instances
  # availability_zones = ["${split(",", lookup(var.azs, var.region))}"]
  security_groups    = ["${aws_security_group.ghost_elb_sg.id}"]
  subnets = ["${aws_subnet.apps_public_subnet.*.id}"]
  cross_zone_load_balancing = true

  listener {
    instance_port     = 2368
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:2368/"
    interval            = 30
  }
}

resource "aws_iam_instance_profile" "codedeploy_profile" {
    name = "codedeploy_profile"
    roles = ["${aws_iam_role.ghost_deploy_role.name}"]
}

# Create the launch_configuration
resource "aws_launch_configuration" "ghost_lc" {
  name          = "ghost_lc"
  image_id      = "${lookup(var.amis, var.region)}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.codedeploy_profile.id}"

  # block device
  root_block_device {
    volume_type = "io1"
    volume_size = "256"
    iops = "300"
  }

  # Security group
  security_groups = ["${aws_security_group.ghost_instances_sg.id}"]
  user_data       = "${file("userdata.sh")}"
  key_name        = "${var.key_name}"
}

# create the ASG 
resource "aws_autoscaling_group" "ghost_asg" {
  availability_zones   = ["${split(",", lookup(var.azs, var.region))}"]
  vpc_zone_identifier = ["${aws_subnet.apps_public_subnet.*.id}"]
  name                 = "ghost_asg"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.ghost_lc.name}"
  load_balancers       = ["${aws_elb.ghost_elb.name}"]
}
