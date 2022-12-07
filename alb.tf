locals {
  web_servers = {
    webserver = {
      machine_type = "t2.micro"
      subnet_id    = aws_subnet.private_us_east_1a.id
    }
    MySQL = {
      machine_type = "t2.micro"
      subnet_id    = aws_subnet.private_us_east_1b.id
    }
  }
}