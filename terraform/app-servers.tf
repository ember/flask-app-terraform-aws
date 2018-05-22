data "template_file" "user_data_api" {
  template = "${file("${path.module}/user_data/app-server.tpl")}"

  vars {
    api_version = "${var.api_version}"
  }
}

resource "aws_elb" "elb_app" {
  name            = "${var.app_name}"
  subnets         = ["${aws_subnet.public_az1.id}", "${aws_subnet.public_az2.id}", "${aws_subnet.public_az3.id}"]
  security_groups = ["${aws_security_group.elb_web.id}"]

  listener {
    instance_port     = "${var.app_port}"
    instance_protocol = "http"
    lb_port           = "${var.app_port}"
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:${var.app_port}/api/kubernetes"
    interval            = 5
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 5
  connection_draining         = true
  connection_draining_timeout = 60
}

data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_configuration" "lc_web_app" {
  lifecycle {
    create_before_destroy = true
  }

  image_id        = "${data.aws_ami.ubuntu_ami.id}"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.app-web.id}"]
  user_data       = "${data.template_file.user_data_api.rendered}"
}

resource "aws_autoscaling_group" "asg_web_app" {
  lifecycle {
    create_before_destroy = true
  }

  name                = "${aws_launch_configuration.lc_web_app.name}"
  load_balancers      = ["${aws_elb.elb_app.name}"]
  vpc_zone_identifier = ["${aws_subnet.private_az1.id}", "${aws_subnet.private_az2.id}", "${aws_subnet.private_az3.id}"]
  min_size            = 1
  max_size            = 2
  desired_capacity    = 2
  min_elb_capacity    = 1

  launch_configuration = "${aws_launch_configuration.lc_web_app.name}"

  depends_on = ["aws_nat_gateway.nat"]

  tags {
    key                 = "Name"
    value               = "${var.app_name}"
    propagate_at_launch = true
  }
}
