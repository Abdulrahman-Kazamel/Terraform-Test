#Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


# Creating Instances here
resource "aws_instance" "Future" {
  ami               = "ami-0574da719dca65348"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "Terraform"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.nic.id
  }

  user_data = <<EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo this is my first web server created by terraform > /var/www/html/index.html'
              EOF
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


# Create Internet Gateway 
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.my-dev.id

}


#Create Route Table

resource "aws_route" "internet" {

  vpc_id = aws_vpc.my_dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    "Name" = "internet-Gateway"
  }

}


# Creating Subnet 
resource "aws_subnet" "my-dev-subnet" {
  vpc_id            = aws_vpc.my-dev.id
  cidr_block        = "10.0.200.0/24" # Defining the CIDR block use 10.0.0.0/24 for demo
  availability_zone = "us_east-1a"


  tags = {
    "Name" = "my_dev_subnet"
  }

}

# Associate subnet with the route

resource "aws_route_table_association" "route_association" {
  subnet_id      = aws_subnet.my-dev-subnet.id
  route_table_id = aws_route.internet.id
}


# create security group with ports (20-80-443)

resource "aws_security_group" "allowed-ports" {
  name = "allowed-ports"
  #description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.my-dev.id
  #ingress traffic == inbound traffic from the internet
  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  # egress traffic == traffic from my server to the internet
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allowed_ports"
  }
}

# create a network interface and associate it to the subnet

resource "aws_network_interface" "nic" {
  subnet_id       = aws_subnet.my-dev-subnet.id
  private_ips     = ["10.0.200.50"] // this ip from same range of my private subnet
  security_groups = aws_security_group.allowed_ports.id

  attachment {
    instance     = aws_instance.Future
    device_index = 0
  }
}


# Assign an elastic IP

resource "aws_eip" "elastic-ip" {
  instance = aws_instance.Future
  vpc      = true
  depends_on = [
    aws_internet_gateway.IGW
  ]
}






















