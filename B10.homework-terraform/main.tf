

#create the vpc
resource "aws_vpc" "sonlh-vpc" {
  cidr_block = var.cidrvpc
  tags       = var.tags
}

resource "aws_subnet" "public" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.sonlh-vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.sonlh-vpc.id
  tags = merge({
    Name = "${var.vpc_name}-public-subnet"
  }, var.tags)
}

resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.sonlh-vpc.id
  tags = merge({
    Name = "${var.vpc_name}-igw"
  }, var.tags)
}

resource "aws_route" "main-route" {
  route_table_id         = aws_vpc.sonlh-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main-igw.id
}

resource "aws_route_table_association" "public-subnet-rtb" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_vpc.sonlh-vpc.main_route_table_id

}

resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.sonlh-vpc.cidr_block, 8, count.index + var.az_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.sonlh-vpc.id
  tags = merge({
    Name = "${var.vpc_name}-private-subnet"
  }, var.tags)
}

resource "aws_eip" "nat_eip" {
  count = var.az_count
  tags = merge({
    Name = "${var.vpc_name}-nat-eip-${count.index}"
  }, var.tags)
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.az_count
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  tags = merge({
    Name = "${var.vpc_name}-nat-${count.index}"
  }, var.tags)
}


resource "aws_route_table" "private_rtb" {
  count  = var.az_count
  vpc_id = aws_vpc.sonlh-vpc.id
  tags = merge({
    ext-name = "${var.vpc_name}-private-rtb-${count.index}"
  }, var.tags)
}

resource "aws_route" "private_nat_route" {
  count                  = var.az_count
  route_table_id         = element(aws_route_table.private_rtb.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gateway.*.id, count.index)
}

resource "aws_route_table_association" "private-subnet-rtb" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private_rtb.*.id, count.index)
}

# resource "aws_instance" "this" {
#   ami             = "ami-04a5ce820a419d6da"
#   instance_type   = "t2.micro"
#   key_name        = "sonlh-key"
#   security_groups = ["sg-0a7ceec95f98b5747"]
#   subnet_id       = "subnet-0b74dc8cc8e2a46e6"
#   tags = {
#     Name      = "sonlh-terraform"
#     CreatedBy = "Son"
#   }
# }
