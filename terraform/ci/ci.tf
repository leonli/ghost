provider "aws" {
    region = "us-west-2"
}

resource "aws_route53_record" "ci_route" {
   zone_id = "Z3OKXUGAIRMFVA"
   name = "ci.awsrun.com"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.ci_server.public_ip}"]
}

resource "aws_instance" "ci_server" {
    ami = "ami-0c31cb6c"
    instance_type = "m4.large"
    key_name = "leon's keypair"
    tags {
        Name = "Jenkins-CI"
    }
    security_groups = ["${aws_security_group.ci_server_sg.name}"]
    root_block_device {
      volume_type = "gp2"
      volume_size = "120"
    }
}

resource "aws_security_group" "ci_server_sg" {
  name = "ci_server_sg"
  description = "CI Server Security Group"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

