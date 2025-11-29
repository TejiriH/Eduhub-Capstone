resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# 1. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public" {
  count      = length(var.public_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets_cidr[count.index]

  availability_zone       = local.global_az_index[var.public_subnets_cidr[count.index]]
  map_public_ip_on_launch = true

  tags = {
    Name                              = "${var.project_name}-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb"          = "1"
    "kubernetes.io/cluster/eduhub-eks" = "owned"
  }
}

resource "aws_subnet" "eks_private" {
  count      = length(var.eks_private_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.eks_private_subnets_cidr[count.index]

  availability_zone = local.global_az_index[var.eks_private_subnets_cidr[count.index]]

  tags = {
    Name                              = "${var.project_name}-eks-private-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/eduhub-eks" = "owned"
  }
}

resource "aws_subnet" "storage_private" {
  count      = length(var.storage_private_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.storage_private_subnets_cidr[count.index]

  availability_zone = local.global_az_index[var.storage_private_subnets_cidr[count.index]]

  tags = {
    Name = "${var.project_name}-storage-private-subnet-${count.index + 1}"
  }
}

# 5. Elastic IP for NAT Gateway (Must be in AZ-1a, where Public Subnet 1 is)
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# 6. NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Place in Public Subnet 1

  tags = {
    Name = "${var.project_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw]
}

# 7. Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# 8. Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# 9. Route Table Associations
# Public Subnets -> Public Route Table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# EKS Private Subnets -> Private Route Table
resource "aws_route_table_association" "eks_private" {
  count          = length(aws_subnet.eks_private)
  subnet_id      = aws_subnet.eks_private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Storage Private Subnets -> Private Route Table
resource "aws_route_table_association" "storage_private" {
  count          = length(aws_subnet.storage_private)
  subnet_id      = aws_subnet.storage_private[count.index].id
  route_table_id = aws_route_table.private.id
}

# 10. S3 VPC Gateway Endpoint (Gateway type - FREE)
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.public.id,
    aws_route_table.private.id,
  ]

  tags = {
    Name = "${var.project_name}-s3-gateway-endpoint"
  }
}

# Data source for current region
data "aws_region" "current" {}

# Default Security Group (allow all within VPC)
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = "-1"
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }
}