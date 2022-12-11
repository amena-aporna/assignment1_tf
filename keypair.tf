# Generating KeyPair 
resource "tls_private_key" "prvtkey" {
  algorithm = "RSA"
}
resource "local_file" "key" {
  content  = tls_private_key.prvtkey.private_key_pem
  filename = "kp_tf.pem"
}
resource "aws_key_pair" "kp" {
  key_name   = "kp_tf"
  public_key = tls_private_key.prvtkey.public_key_openssh
}

