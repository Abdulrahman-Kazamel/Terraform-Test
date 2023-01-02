#Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


# Creating Instances here
resource "aws_instance" "Future" {
  ami           = "ami-0574da719dca65348"
  instance_type = "t2.micro"

  tags = {
    "Name" = "Future_x"
  }
}

# Creating VPC here
resource "aws_vpc" "my-dev" {
  cidr_block = "10.0.0.0/16" # Defining the CIDR block use 10.0.0.0/24 for demo
  tags = {
    "Name" = "my_dev_VPC"
  }

}


# Creating Subnet here
resource "aws_subnet" "my-dev-subnet" {
  vpc_id     = aws_vpc.my-dev.id
  cidr_block = "10.0.200.0/24" # Defining the CIDR block use 10.0.0.0/24 for demo
  tags = {
    "Name" = "my_dev_subnet"
  }

}


