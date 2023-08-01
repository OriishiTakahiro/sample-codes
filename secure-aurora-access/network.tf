# ---------------------
# VPC
# ---------------------

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "sample-vpc"
  }
}

# ---------------------
# サブネット
# ---------------------

resource "aws_subnet" "nat" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "NAT"
  }
}

resource "aws_subnet" "local_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "Local"
  }
}

resource "aws_subnet" "local_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "Local"
  }
}

resource "aws_db_subnet_group" "aurora" {
  name       = "sample-aurora-cluster"
  subnet_ids = [aws_subnet.local_1a.id, aws_subnet.local_1c.id]
}

# ---------------------
# ゲートウェイ
# ---------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "sample-igw"
  }
}

resource "aws_eip" "natgw" {
  tags = {
    Name = "sample-natgw"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw.id
  subnet_id     = aws_subnet.nat.id
  tags = {
    Name = "NAT GW"
  }
}

# ---------------------
# ルーティング
# ---------------------

resource "aws_route_table" "to_igw" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "to_natgw" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }
}

resource "aws_route_table_association" "nat_to_igw" {
  subnet_id      = aws_subnet.nat.id
  route_table_id = aws_route_table.to_igw.id
}

resource "aws_route_table_association" "local_1a_to_natgw" {
  subnet_id      = aws_subnet.local_1a.id
  route_table_id = aws_route_table.to_natgw.id
}

resource "aws_route_table_association" "local_1c_to_natgw" {
  subnet_id      = aws_subnet.local_1c.id
  route_table_id = aws_route_table.to_natgw.id
}
