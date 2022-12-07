# Generating KeyPair 
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

