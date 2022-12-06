# Creating an Internet Gateway for the VPC

resource "aws_internet_gateway" "igw" {
  
  # VPC in which it has to be created!
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IG-Public-&-Private-VPC"
  }
}