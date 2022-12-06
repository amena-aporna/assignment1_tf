
# Creating a New Key
# Generating KeyPair for Accessing DB
resource "tls_private_key" "dbkey" {
  algorithm = "RSA"
}
resource "local_file" "myterrakey" {
  content  = tls_private_key.dbkey.private_key_pem
  filename = "dbkp_tf.pem"
}
resource "aws_key_pair" "dbkp" {
  key_name   = "dbkp_tf"
  public_key = tls_private_key.dbkey.public_key_openssh
}


///////
//variable "key_path" {
  //description = "SSH Public Key path"
  //default = "public_key"
//}
# Define SSH key pair for our instances
//resource "aws_key_pair" "Key-Pair" {
  //key_name = "MyKeyFinal"
  //public_key = file(var.key_path)
//}


#variable "ami" {
  #description = "Amazon Linux AMI"
  #default = "ami-14c5486b"
#}


 

# # Creating Public subnet!
# resource "aws_subnet" "subnet1" {
#   depends_on = [
#     aws_vpc.custom
#   ]
  
#   # VPC in which subnet has to be created!
#   vpc_id = aws_vpc.custom.id
  
#   # IP Range of this subnet
#   cidr_block = "192.168.0.0/24"
  
#   # Data Center of this subnet.
#   availability_zone = "us-east-1a"
  
#   # Enabling automatic public IP assignment on instance launch!
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "Public Subnet"
#   }
# }


# # Creating Public subnet!
# resource "aws_subnet" "subnet2" {
#   depends_on = [
#     aws_vpc.custom,
#     aws_subnet.subnet1
#   ]
  
#   # VPC in which subnet has to be created!
#   vpc_id = aws_vpc.custom.id
  
#   # IP Range of this subnet
#   cidr_block = "192.168.1.0/24"
  
#   # Data Center of this subnet.
#   availability_zone = "us-east-1b"
  
#   tags = {
#     Name = "Private Subnet"
#   }
# }

 
# # Creating an Internet Gateway for the VPC
# resource "aws_internet_gateway" "Internet_Gateway" {
#   depends_on = [
#     aws_vpc.custom,
#     aws_subnet.subnet1,
#     aws_subnet.subnet2
#   ]
  
#   # VPC in which it has to be created!
#   vpc_id = aws_vpc.custom.id

#   tags = {
#     Name = "IG-Public-&-Private-VPC"
#   }
# }



# # Creating an Route Table for the public subnet!
# resource "aws_route_table" "Public-Subnet-RT" {
#   depends_on = [
#     aws_vpc.custom,
#     aws_internet_gateway.Internet_Gateway
#   ]

#    # VPC ID
#   vpc_id = aws_vpc.custom.id

#   # NAT Rule
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.Internet_Gateway.id
#   }

#   tags = {
#     Name = "Route Table for Internet Gateway"
#   }
# }

# # Creating a resource for the Route Table Association!
# resource "aws_route_table_association" "RT-IG-Association" {

#   depends_on = [
#     aws_vpc.custom,
#     aws_subnet.subnet1,
#     aws_subnet.subnet2,
#     aws_route_table.Public-Subnet-RT
#   ]

# # Public Subnet ID
#   subnet_id      = aws_subnet.subnet1.id

# #  Route Table ID
#   route_table_id = aws_route_table.Public-Subnet-RT.id
# }

# Creating a Security Group for WordPress
resource "aws_security_group" "WS-SG" {

  depends_on = [
    aws_vpc.custom,
    aws_subnet.subnet1,
    aws_subnet.subnet2
  ]

  description = "HTTP, PING, SSH"

  # Name of the security Group!
  name = "webserver-sg"
  
  # VPC ID in which Security group has to be created!
  vpc_id = aws_vpc.custom.id

  # Created an inbound rule for webserver access!
  ingress {
    description = "HTTP for webserver"
    from_port   = 80
    to_port     = 80

    # Here adding tcp instead of http, because http in part of tcp only!
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Created an inbound rule for ping
  ingress {
    description = "Ping"
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Created an inbound rule for SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22

    # Here adding tcp instead of ssh, because ssh in part of tcp only!
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outward Network Traffic for the WordPress
  egress {
    description = "output from webserver"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Creating security group for MySQL
resource "aws_security_group" "MySQL-SG" {

  depends_on = [
    aws_vpc.custom,
    aws_subnet.subnet1,
    aws_subnet.subnet2,
    aws_security_group.WS-SG
  ]

  description = "MySQL Access only from the Webserver Instances!"
  name = "mysql-sg"
  vpc_id = aws_vpc.custom.id

  # Created an inbound rule for MySQL
  ingress {
    description = "MySQL Access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.WS-SG.id]
  }

  egress {
    description = "output from MySQL"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# Creating security group for Bastion Host/Jump Box
resource "aws_security_group" "BH-SG" {

  depends_on = [
    aws_vpc.custom,
    aws_subnet.subnet1,
    aws_subnet.subnet2
  ]

  description = "MySQL Access only from the Webserver Instances!"
  name = "bastion-host-sg"
  vpc_id = aws_vpc.custom.id

  # Created an inbound rule for Bastion Host SSH
  ingress {
    description = "Bastion Host SG"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "output from Bastion Host"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# Creating security group for MySQL Bastion Host Access
resource "aws_security_group" "DB-SG-SSH" {

  depends_on = [
    aws_vpc.custom,
    aws_subnet.subnet1,
    aws_subnet.subnet2,
    aws_security_group.BH-SG
  ]

  description = "MySQL Bastion host access for updates!"
  name = "mysql-sg-bastion-host"
  vpc_id = aws_vpc.custom.id

  # Created an inbound rule for MySQL Bastion Host
  ingress {
    description = "Bastion Host SG"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.BH-SG.id]
  }

  egress {
    description = "output from MySQL BH"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# # Creating an AWS instance for the Webserver!
# resource "aws_instance" "webserver" {

#   depends_on = [
#     aws_vpc.custom,
#     aws_subnet.subnet1,
#     aws_subnet.subnet2,
#     aws_security_group.BH-SG,
#     aws_security_group.DB-SG-SSH
#   ]
  
#   # AMI ID 
#   ami  = var.ami
#   instance_type = "t2.micro"
#   subnet_id = aws_subnet.subnet1.id

  
#   //key_name = "dbkp_tf"
  
#   # Security groups to use!
#   vpc_security_group_ids = [aws_security_group.WS-SG.id]

#   tags = {
#    Name = "Webserver_From_Terraform"
#   }
  
#   user_data = <<EOF
# #!/bin/bash
# sudo yum update -y
# sudo yum install php php-mysqlnd httpd -y
# wget https://wordpress.org/wordpress-4.8.14.tar.gz
# tar -xzf wordpress-4.8.14.tar.gz
# sudo cp -r wordpress /var/www/html/
# sudo chown -R apache.apache /var/www/html/
# sudo systemctl start httpd
# sudo systemctl enable httpd
# sudo systemctl restart httpd
# EOF

# #   # Installing required softwares into the system!
# #   connection {
# #     type = "ssh"
# #     user = "root"
# #     key_name = aws_key_pair.dbkp.key_name
# #     # associate_public_ip_address = false

# #     # host = aws_instance.webserver.public_ip
# #     host = self.public_ip
# #   }

# #   # Code for installing the softwares!
# #   provisioner "remote-exec" {
# #     inline = [
# #         "sudo yum update -y",
# #         "sudo yum install php php-mysqlnd httpd -y",
# #         "wget https://wordpress.org/wordpress-4.8.14.tar.gz",
# #         "tar -xzf wordpress-4.8.14.tar.gz",
# #         "sudo cp -r wordpress /var/www/html/",
# #         "sudo chown -R apache.apache /var/www/html/",
# #         "sudo systemctl start httpd",
# #         "sudo systemctl enable httpd",
# #         "sudo systemctl restart httpd"
# #     ]
# #   }
# }


# # Creating an AWS instance for the MySQL! 
# resource "aws_instance" "MySQL" {
#   depends_on = [
#     aws_instance.webserver,
#   ]


#   ami  = var.ami
#   instance_type = "t2.micro"
#   subnet_id = aws_subnet.subnet2.id

  
#   //key_name = "dbkp_tf"

#   # Attaching 2 security groups here, 1 for the MySQL Database access by the Web-servers,
#   # & other one for the Bastion Host access for applying updates & patches!
#   vpc_security_group_ids = [aws_security_group.MySQL-SG.id, aws_security_group.DB-SG-SSH.id]

#   tags = {
#    Name = "MySQL_Terraform"
#   }
# }


# # Creating an AWS instance for the Bastion Host, It should be launched in the public Subnet!
# # resource "aws_instance" "Bastion-Host" {
# #    depends_on = [
# #     aws_instance.webserver,
# #      aws_instance.MySQL
# #   ]
  
# #   ami  = var.ami
# #   instance_type = "t2.micro"
# #   subnet_id = aws_subnet.subnet1.id

  
# #   //key_name = "MyKeyFinal"
   
# #   # Security group ID's
# #   vpc_security_group_ids = [aws_security_group.BH-SG.id]
# #   tags = {
# #    Name = "Bastion_Host_Terraform"
# #   }
# # }


