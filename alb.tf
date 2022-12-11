# sg for alb
 resource "aws_security_group" "alb_eg1" {
   name   = "alb-eg1"
   vpc_id = aws_vpc.main.id

  ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
 }



#create target group
resource "aws_lb_target_group" "front" {
  name       = "application-front"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.main.id
  

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
  target_ids        = [aws_instance.webserver.id,aws_instance.MySQL.id]
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


