 terraform {
   backend "s3" {
     bucket         = "tf-flask-api"
     key            = "api-app/terraform.tfstate"
     dynamodb_table = "tf-lock-state"
     region         = "eu-west-2"
   }
 }

provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  version    = "~> 1.10"
}

resource "aws_vpc" "vpc_app" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = "true"

  tags {
    Name = "${var.app_name}-vpc"
  }
}
