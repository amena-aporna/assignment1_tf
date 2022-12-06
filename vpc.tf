# Creating a VPC

resource "aws_vpc" "main" {
  
  # IP Range for the VPC
  cidr_block = "192.168.0.0/23"
  
  # Enabling automatic hostname assigning
  enable_dns_hostnames = true
  tags = {
    Name = "main"
  }
}
