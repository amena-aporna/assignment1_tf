# Creating an AWS instance Public for the Webserver! zz
resource "aws_instance" "webserver" {

  depends_on = [
    aws_vpc.main,
    aws_subnet.public_us_east_1a,
    aws_subnet.public_us_east_1b,
    aws_subnet.private_us_east_1a,
    aws_subnet.private_us_east_1b,
    aws_security_group.BH-SG,
    aws_security_group.DB-SG-SSH
  ]
  
  # AMI ID 
  ami  = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_us_east_1a.id

  
  //key_name = "dbkp_tf"
  
  # Security groups to use!
  vpc_security_group_ids = [aws_security_group.WS-SG.id]

  tags = {
   Name = "Webserver_From_Terraform"
  }
  
  user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum install php php-mysqlnd httpd -y
wget https://wordpress.org/wordpress-4.8.14.tar.gz
tar -xzf wordpress-4.8.14.tar.gz
sudo cp -r wordpress /var/www/html/
sudo chown -R apache.apache /var/www/html/
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl restart httpd
EOF

#   # Installing required softwares into the system!
#   connection {
#     type = "ssh"
#     user = "root"
#     key_name = aws_key_pair.dbkp.key_name
#     # associate_public_ip_address = false

#     # host = aws_instance.webserver.public_ip
#     host = self.public_ip
#   }

#   # Code for installing the softwares!
#   provisioner "remote-exec" {
#     inline = [
#         "sudo yum update -y",
#         "sudo yum install php php-mysqlnd httpd -y",
#         "wget https://wordpress.org/wordpress-4.8.14.tar.gz",
#         "tar -xzf wordpress-4.8.14.tar.gz",
#         "sudo cp -r wordpress /var/www/html/",
#         "sudo chown -R apache.apache /var/www/html/",
#         "sudo systemctl start httpd",
#         "sudo systemctl enable httpd",
#         "sudo systemctl restart httpd"
#     ]
#   }
}


# Creating an AWS instance Private for the MySQL! 
resource "aws_instance" "MySQL" {
  depends_on = [
    aws_instance.webserver,
  ]


  ami  = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private_us_east_1a.id

  
  //key_name = "dbkp_tf"

  # Attaching 2 security groups here, 1 for the MySQL Database access by the Web-servers,
  # & other one for the Bastion Host access for applying updates & patches!
  vpc_security_group_ids = [aws_security_group.MySQL-SG.id, aws_security_group.DB-SG-SSH.id]

  tags = {
   Name = "MySQL_Terraform"
  }
}


# Creating an AWS instance for the Bastion Host, It should be launched in the public Subnet!
resource "aws_instance" "Bastion-Host" {
   depends_on = [
    aws_instance.webserver,
     aws_instance.MySQL,
     #aws_subnet.public_us_east_1a,
     #aws_subnet.public_us_east_1b
  ]
  
  ami  = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_us_east_1b.id
  #subnet_id = aws_subnet.public_us_east_1b

  
  //key_name = "MyKeyFinal"
   
  # Security group ID's
  vpc_security_group_ids = [aws_security_group.BH-SG.id]
  tags = {
   Name = "Bastion_Host_Terraform"
  }
}




