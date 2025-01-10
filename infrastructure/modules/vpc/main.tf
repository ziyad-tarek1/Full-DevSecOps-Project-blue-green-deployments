resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                = "${var.project_name}-VPC"
    "kubernetes.io/cluster/${var.eks_name}" = "shared"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index].cidr
  availability_zone = var.private_subnets[count.index].az

  tags = {
    Name                                = "${var.project_name}-private-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.eks_name}" = "shared"
    "kubernetes.io/role/internal-elb"   = "1"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index].cidr
  availability_zone       = var.public_subnets[count.index].az
  map_public_ip_on_launch = true

  tags = {
    Name                                = "${var.project_name}-public-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.eks_name}" = "shared"
    "kubernetes.io/role/elb"            = "1"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-IGW"
  }
}

resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-NAT-EIP"
  }
}



resource "aws_nat_gateway" "nat" {
  count       = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-NAT"
  }

  depends_on = [aws_internet_gateway.gw]
}



resource "aws_route_table" "private" {
  count = var.create_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[0].id
  }

  tags = {
    Name = "${var.project_name}-private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.project_name}-public"
  }
}

resource "aws_route_table_association" "private" {
  for_each = { for idx, subnet in aws_subnet.private : idx => subnet }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_route_table_association" "public" {
  for_each = { for idx, subnet in aws_subnet.public : idx => subnet }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
