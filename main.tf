# Provider configuration
provider "aws" {
  region = "eu-central-1" # replace with your desired region
}

# Variables
variable "ami_id" {
  default = "ami-01a2825a801771f57" # Ubuntu 22.04 LTS AMI ID
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "ackey"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub" # replace with the path to your public key file
}

#Data

data "template_file" "user_data_ansible_srv" {
  template = file("user_data_ansible_srv.sh")
}


data "template_file" "user_data_client" {
  template = file("user_data_client.sh")
}

# Resources


resource "aws_security_group" "ingress" {
  vpc_id      = aws_vpc.example_vpc.id
  name_prefix = "ingress"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ansible_srv" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = data.template_file.user_data_ansible_srv.rendered
  vpc_security_group_ids = [

    aws_security_group.ingress.id,
  ]

  subnet_id                   = aws_subnet.example_public_subnet.id # associate instance with public subnet
  associate_public_ip_address = true                                # assign a public IP address to the instance
}

resource "aws_instance" "test_client" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = data.template_file.user_data_client.rendered
  vpc_security_group_ids = [

    aws_security_group.ingress.id,
  ]

  subnet_id                   = aws_subnet.example_public_subnet.id # associate instance with public subnet
  associate_public_ip_address = true                                # assign a public IP address to the instance
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example_vpc"
  }
}

resource "aws_internet_gateway" "example_gateway" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "example_gateway"
  }
}

resource "aws_subnet" "example_public_subnet" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "example_public_subnet"
  }
}

resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_gateway.id
  }

  tags = {
    Name = "example_route_table"
  }
}

resource "aws_route_table_association" "example_association" {
  subnet_id      = aws_subnet.example_public_subnet.id
  route_table_id = aws_route_table.example_route_table.id
}

resource "aws_key_pair" "ssh_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Output variables
output "ansible_srv_public_ip" {
  value = aws_instance.ansible_srv.public_ip
}

# Output variables
output "test_client_public_ip" {
  value = aws_instance.test_client.public_ip
}

# Output variables
output "ansible_srv_private_ip" {
  value = aws_instance.ansible_srv.private_ip
}

output "test_client_private_ip" {
  value = aws_instance.test_client.private_ip
}