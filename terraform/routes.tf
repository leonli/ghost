resource "aws_route53_record" "ghost" {
  zone_id = "${var.hosted_zone_id}"
  name = "ghost.awsrun.com"
  type = "A"

  alias {
    name = "${aws_elb.ghost_elb.dns_name}"
    zone_id = "${aws_elb.ghost_elb.zone_id}"
    evaluate_target_health = true
  }
}
