// AWS specific vars
variable "aws_access_key" {
  default     = ""
  description = "AWS access key (AWS_ACCESS_KEY_ID)."
}

variable "aws_secret_key" {
  default     = ""
  description = "AWS secret key (AWS_SECRET_ACCESS_KEY)."
}

variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-2"
}

// VPC vars
variable "availability_zones" {
  default     = "eu-west-2a,eu-west-2b,eu-west-2c"
  description = "List of availability zones"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_az1_cidr" {
  description = "CIDR for az1 public subnet"
  default     = "10.0.10.0/24"
}

variable "public_subnet_az2_cidr" {
  description = "CIDR for az2 public subnet"
  default     = "10.0.11.0/24"
}

variable "public_subnet_az3_cidr" {
  description = "CIDR for az3 public subnet"
  default     = "10.0.12.0/24"
}

variable "private_subnet_az1_cidr" {
  description = "CIDR for az1 private subnet"
  default     = "10.0.20.0/24"
}

variable "private_subnet_az2_cidr" {
  description = "CIDR for az2 private subnet"
  default     = "10.0.21.0/24"
}

variable "private_subnet_az3_cidr" {
  description = "CIDR for az3 private subnet"
  default     = "10.0.22.0/24"
}

// EC2 vars

variable "instance_type" {
  description = "Instance type"
  default     = "t1.micro"
}

variable "app_name" {
  description = "app name to be deployed"
  default     = "flask-api"
}

variable "app_port" {
  description = "app port to be served"
  default     = "80"
}

variable "api_version" {
  description = "build version from containers"
  default     = "latest"
}
