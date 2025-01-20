data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  // ...existing code...
}

resource "aws_subnet" "public" {
  count                   = var.number_of_azs
 
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  // ...existing code...
}

resource "aws_subnet" "private" {
  count             = var.number_of_azs
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, var.number_of_azs + count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  // ...existing code...
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-internet-gateway"
  }
}

