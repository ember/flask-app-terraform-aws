resource "aws_eip" "nat_gw_ip" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_gw_ip.id}"
  subnet_id     = "${aws_subnet.public_az1.id}"
}

resource "aws_subnet" "private_az1" {
  vpc_id                  = "${aws_vpc.vpc_app.id}"
  cidr_block              = "${var.private_subnet_az1_cidr}"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags {
    Name = "private az1"
  }
}

resource "aws_subnet" "private_az2" {
  vpc_id                  = "${aws_vpc.vpc_app.id}"
  cidr_block              = "${var.private_subnet_az2_cidr}"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false

  tags {
    Name = "private az2"
  }
}

resource "aws_subnet" "private_az3" {
  vpc_id                  = "${aws_vpc.vpc_app.id}"
  cidr_block              = "${var.private_subnet_az3_cidr}"
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = false

  tags {
    Name = "private az3"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc_app.id}"

  tags {
    Name = "Private route table"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

resource "aws_route_table_association" "private_az1" {
  subnet_id      = "${aws_subnet.private_az1.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private_az2" {
  subnet_id      = "${aws_subnet.private_az2.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private_az3" {
  subnet_id      = "${aws_subnet.private_az3.id}"
  route_table_id = "${aws_route_table.private.id}"
}
