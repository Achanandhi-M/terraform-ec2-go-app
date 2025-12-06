#############################################
# Availability Zones
#############################################
data "aws_availability_zones" "available" {}

#############################################
# VPC
#############################################
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "assignment-vpc"
  }
}

#############################################
# Public Subnets
#############################################
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.available.names[tonumber(each.key)]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${each.key}"
  }
}

#############################################
# Private Subnets
#############################################
resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.available.names[tonumber(each.key)]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-${each.key}"
  }
}

#############################################
# Internet Gateway
#############################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "assignment-igw"
  }
}

#############################################
# Elastic IP for NAT
#############################################
resource "aws_eip" "nat" {
  domain = "vpc"
}

#############################################
# NAT Gateway (in first public subnet)
#############################################
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["0"].id

  depends_on = [aws_internet_gateway.igw]
}

#############################################
# Public Route Table
#############################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

#############################################
# Associate Public Subnets
#############################################
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

#############################################
# Private Route Table
#############################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

#############################################
# Associate Private Subnets
#############################################
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
