resource "aws_subnet" "public" {
  count = length(var.bsod_availability_zones)

  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = var.bsod_availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-${var.bsod_availability_zones[count.index]}"
    Type = "Public"
  }

  depends_on = [aws_vpc.my_vpc]
}

resource "aws_route_table_association" "public" {
  count = length(var.bsod_availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

  depends_on = [
    aws_subnet.public,
    aws_route_table.public
  ]
}

resource "aws_subnet" "private" {
  count = length(var.bsod_availability_zones)

  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = var.bsod_availability_zones[count.index]

  tags = {
    Name = "${var.vpc_name}-private-${var.bsod_availability_zones[count.index]}"
    Type = "Private"
  }

  depends_on = [aws_vpc.my_vpc]
}

# Elastic IP for each NAT Gateway
resource "aws_eip" "nat" {
  count = length(var.bsod_availability_zones)

  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-NAT-EIP-${var.bsod_availability_zones[count.index]}"
  }

  depends_on = [aws_internet_gateway.igw] # Ensures IGW exists for EIP allocation
}

# NAT Gateway - one per AZ, placed in the matching public subnet
resource "aws_nat_gateway" "this" {
  count = length(var.bsod_availability_zones)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.vpc_name}-NAT-${var.bsod_availability_zones[count.index]}"
  }

  depends_on = [
    aws_vpc.my_vpc,
    aws_subnet.public,
    aws_eip.nat
  ]
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private" {
  count          = length(var.bsod_availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id

  depends_on = [
    aws_subnet.private,
    aws_route_table.private
  ]
}