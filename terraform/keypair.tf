resource "aws_key_pair" "ghost_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}
