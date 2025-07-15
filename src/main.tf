# VPC
resource "aws_vpc" "pe_vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "PE VPC"
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
