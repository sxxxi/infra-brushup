# VPC
resource "aws_vpc" "pe_vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "PE VPC"
  }
}

# Security group
resource "aws_security_group" "http_sg" {
  vpc_id = aws_vpc.pe_vpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow HTTP"
  }
}

resource "aws_security_group" "https_sg" {
  vpc_id = aws_vpc.pe_vpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow HTTPS"
  }
}

resource "aws_security_group" "ssh_sg" {
  vpc_id = aws_vpc.pe_vpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow SSH"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.pe_vpc.id
  cidr_block = "192.168.1.0/24"
  tags = {
    Name = "PE Public Subnet"
  }
}

# IGW
resource "aws_internet_gateway" "pe_igw" {
  vpc_id = aws_vpc.pe_vpc.id
  tags = {
    Name = "PE IGW"
  }
}

# Public subnet route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.pe_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pe_igw.id
  }
  tags = {
    Name = "Public Route Table"
  }
}

# Associate route table to subnet
resource "aws_route_table_association" "public_rt" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id = aws_subnet.public_subnet.id
}

# Elastic IP
resource "aws_eip" "eip" {}

# NAT
resource "aws_nat_gateway" "nat" {
  subnet_id = aws_subnet.public_subnet.id
  allocation_id = aws_eip.eip.id
  tags = {
    Name = "PE NAT"
  }
}

resource "aws_key_pair" "ssher" {
  key_name = "the_ssh_key"
  public_key = var.public_key
  tags = {
    Name = "SSH Key"
  }
}

# EC2
resource "aws_instance" "pe_server" {
  ami = "ami-054400ced365b82a0"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  key_name = aws_key_pair.ssher.key_name
  security_groups = [
    aws_security_group.ssh_sg.id,
    aws_security_group.http_sg.id,
    aws_security_group.https_sg.id
  ]
}
