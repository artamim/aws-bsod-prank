resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.vpc_name}-IGW"
  }

  depends_on = [aws_vpc.my_vpc]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-Public-RT"
  }

  depends_on = [
    aws_vpc.my_vpc,
    aws_internet_gateway.igw
  ]
}

resource "aws_route_table" "private" {
  count  = length(var.bsod_availability_zones)
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.vpc_name}-Private-RT-${var.bsod_availability_zones[count.index]}"
  }

  depends_on = [aws_vpc.my_vpc]
}

# Default route in private RT: 0.0.0.0/0 -> NAT Gateway in the same AZ as the private subnet
resource "aws_route" "private_nat" {
  count                  = length(var.bsod_availability_zones)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id

  depends_on = [
    aws_route_table.private,
    aws_nat_gateway.this
  ]
}