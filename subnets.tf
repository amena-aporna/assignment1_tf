
# Creating Public subnet!
resource "aws_subnet" "private_us_east_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.16.0/28"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "private-us-east-1a"
  }
}

resource "aws_subnet" "private_us_east_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.16.16/28"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "private-us-east-1b"
  }
}


# Creating Public subnet!
resource "aws_subnet" "public_us_east_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "192.168.16.32/28"
  availability_zone       = "us-east-1a"
 # Enabling automatic public IP assignment on instance launch! 
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-us-east-1a"
  }
}

resource "aws_subnet" "public_us_east_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "192.168.16.48/28"
  availability_zone       = "us-east-1b"
 # Enabling automatic public IP assignment on instance launch! 
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-us-east-1b"
  }
}