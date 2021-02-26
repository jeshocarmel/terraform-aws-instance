# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}

resource "aws_vpc" "jeshos-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "Jeshos-terraform-vpc"
  }
}

output "created_vpc" {
  value       = aws_vpc.jeshos-vpc.id
}

resource "aws_subnet" "jeshos-subnet" {
  vpc_id     = aws_vpc.jeshos-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone

  tags = {
    Name = "Jeshos-terraform-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.jeshos-vpc.id

  tags = {
    Name = "jeshos-igw"
  }
}

resource "aws_default_route_table" "r" {
  default_route_table_id = aws_vpc.jeshos-vpc.default_route_table_id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.env}-default route table"
  }
}

resource "aws_default_security_group" "jeshos-vpc-sg" {
  vpc_id      = aws_vpc.jeshos-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "open app port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

data "aws_ami" "amzon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amzon_linux.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.jeshos-subnet.id
  vpc_security_group_ids= [aws_default_security_group.jeshos-vpc-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entry-script.sh")

  tags = {
    Name = "Jeshos-server"
  }
}
