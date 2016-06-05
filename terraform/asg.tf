## Define the ELB security group first 
resource "aws_security_group" "ghost_elb_sg" {
  name        = "ghost_elb_sg"
  description = "The security gourp defined for ELB"

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
    from_port       = 80
    to_port         = 80
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
  availability_zones = ["${split(",", lookup(var.azs, var.region))}"]
  security_groups    = ["${aws_security_group.ghost_elb_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}

# Create the launch_configuration
resource "aws_launch_configuration" "ghost_lc" {
  name          = "ghost_lc"
  image_id      = "${lookup(var.amis, var.region)}"
  instance_type = "${var.instance_type}"

  # Security group
  security_groups = ["${aws_security_group.ghost_instances_sg.id}"]
  user_data       = "${file("userdata.sh")}"
  key_name        = "${var.key_name}"
}

# create the ASG 
resource "aws_autoscaling_group" "ghost_asg" {
  availability_zones   = ["${split(",", lookup(var.azs, var.region))}"]
  name                 = "ghost_asg"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.ghost_lc.name}"
  load_balancers       = ["${aws_elb.ghost_elb.name}"]
}
