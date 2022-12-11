# Creating an AWS instance Public for the Webserver!
resource "aws_instance" "webserver" {

  depends_on = [
    aws_vpc.main,
    aws_subnet.public_us_east_1a,
    aws_subnet.public_us_east_1b,
    aws_subnet.private_us_east_1a,
    aws_subnet.private_us_east_1b,
  ]


  # AMI ID 
  ami  = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_us_east_1a.id

  key_name = aws_key_pair.kp.key_name

  
  # Security groups to use!
  vpc_security_group_ids = [aws_security_group.WS-SG.id]
  associate_public_ip_address = true 

  tags = {
   Name = "Webserver_Terraform"
  }

  user_data = <<EOF
     yum update -y
                 amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
                 yum install -y httpd mariadb-server
                 systemctl start httpd
                 systemctl enable httpd
                 usermod -a -G apache ec2-user
                 chown -R ec2-user:apache /var/www
                 chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \\;
                find /var/www -type f -exec sudo chmod 0664 {} \\;
                echo \"<?php phpinfo(); ?>\" > /var/www/html/index.php
	EOF

}



# Creating an AWS instance Private for the MySQL! 
resource "aws_instance" "MySQL" {
  depends_on = [
    aws_instance.webserver,
  ]


  ami  = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private_us_east_1a.id

  key_name = aws_key_pair.kp.key_name

  # Attaching 2 security groups here, 1 for the MySQL Database access by the Web-servers,
  # & other one for the Bastion Host access for applying updates & patches!
  vpc_security_group_ids = [aws_security_group.MySQL-SG.id]
  
  tags = {
   Name = "MySQL_Terraform"
  }

}



