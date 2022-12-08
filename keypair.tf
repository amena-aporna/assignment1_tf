# Generating KeyPair 
resource "tls_private_key" "keyp" {
  algorithm = "RSA"
}
resource "local_file" "mytfakey" {
  content  = tls_private_key.keyp.private_key_pem
  filename = "kp_tf.pem"
}
resource "aws_key_pair" "skp" {
  key_name   = "kp_tf"
  public_key = tls_private_key.keyp.public_key_openssh
}

