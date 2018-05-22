output "elb_address" {
  value = "${aws_elb.elb_app.dns_name}"
}

output "app_version" {
  value = "${var.api_version}"
}
