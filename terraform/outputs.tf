output "ghost_elb_address" {
  value = "${aws_elb.ghost_elb.dns_name}"
}


