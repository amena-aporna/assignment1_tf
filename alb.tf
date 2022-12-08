#new alb



# resource "aws_security_group" "ec2_eg1" {
#   name   = "ec2-eg1"
#   vpc_id = aws_vpc.main.id
# }

 resource "aws_security_group" "alb_eg1" {
   name   = "alb-eg1"
   vpc_id = aws_vpc.main.id
 }


# resource "aws_security_group_rule" "ingress_ec2_traffic" {
#   type                     = "ingress"
#   from_port                = 8080
#   to_port                  = 8080
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.ec2_eg1.id
#   source_security_group_id = aws_security_group.alb_eg1.id
# }

# resource "aws_security_group_rule" "ingress_ec2_health_check" {
#   type                     = "ingress"
#   from_port                = 8081
#   to_port                  = 8081
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.ec2_eg1.id
#   source_security_group_id = aws_security_group.alb_eg1.id
# }

# resource "aws_security_group_rule" "full_egress_ec2" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   security_group_id = aws_security_group.ec2_eg1.id
#   cidr_blocks       = ["0.0.0.0/0"]
# }



# resource "aws_security_group_rule" "ingress_alb_traffic" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   security_group_id = aws_security_group.alb_eg1.id
#   cidr_blocks       = ["0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "egress_alb_traffic" {
#   type                     = "egress"
#   from_port                = 8080
#   to_port                  = 8080
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.alb_eg1.id
#   source_security_group_id = aws_security_group.ec2_eg1.id
# }

# resource "aws_security_group_rule" "egress_alb_health_check" {
#   type                     = "egress"
#   from_port                = 8081
#   to_port                  = 8081
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.alb_eg1.id
#   source_security_group_id = aws_security_group.ec2_eg1.id
# }


# resource "aws_instance" "my_app_eg1" {
#   for_each = local.web_servers

#   ami           = "ami-0b0dcb5067f052a63"
#   instance_type = each.value.machine_type
#   key_name      = "dbkp_tf"
#   subnet_id     = each.value.subnet_id

#   vpc_security_group_ids = [aws_security_group.ec2_eg1.id]

#   tags = {
#     Name = each.key
#   }
# }

#create target group
resource "aws_lb_target_group" "front" {
  name       = "application-front"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.main.id
  # slow_start = 0

  # load_balancing_algorithm_type = "round_robin"

  # stickiness {
  #   enabled = false
  #   type    = "lb_cookie"
  # }

  health_check {
    enabled             = true
    port                = 8081
    interval            = 30
    protocol            = "HTTP"
    path                = "/"
    matcher             = 200
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# attaching target group to instances
resource "aws_lb_target_group_attachment" "attach-app1" {
  target_group_arn = aws_lb_target_group.front.arn
  target_id        = aws_instance.webserver.id
  
  port             = 80
}


#creating load balancer
resource "aws_lb" "lbfront" {
  name               = "lbfront"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_eg1.id]

  subnets = [
    aws_subnet.public_us_east_1a.id,
    aws_subnet.public_us_east_1b.id
  ]
  enable_deletion_protection = false
  
}

 

# listener checks for connection requests
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lbfront.arn
  port              = "80"
  protocol          = "HTTP"

  default_action { 
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.arn
  }
}


