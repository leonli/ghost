output "ghost_elb_address" {
  value = "${aws_elb.ghost_elb.dns_name}"
}

output "db_instance_address" {
  value = "${aws_db_instance.ghost_rds.address}"
}

output "config_file" {
  value = "${template_file.config_file.rendered}"
}

