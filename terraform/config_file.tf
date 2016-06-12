resource "template_file" "config_file" {
  template = "${file("config.tpl")}"
  vars {
    ghost_domain = "${var.ghost_domain}"
    rds_address = "${aws_db_instance.ghost_rds.address}"
    db_username = "${var.db_username}"
    db_password = "${var.db_password}"
    db_name = "${var.db_name}"
  }
}
