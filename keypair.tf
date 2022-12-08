# Generating KeyPair 
resource "tls_private_key" "key" {
  algorithm = "RSA"
}
resource "local_file" "myterrakey" {
  content  = tls_private_key.key.private_key_pem
  filename = "tf.pem"
}
resource "aws_key_pair" "dbkp" {
  key_name   = "tf"
  public_key = tls_private_key.key.public_key_openssh
}

