#--------------------------------------------------------------------------------------------------------#
#    Create Ubuntu server and run my docker image
resource "aws_instance" "web-server-instance" {
  ami               = var.image_id
  instance_type     = "t2.micro"
  availability_zone = "eu-central-1a"
  key_name          = "hamada_best_key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic-1.id
  }

  user_data = var.what_to_do

  tags = {
    Name = "web-server"
  }
}





#--------------------------------------------------------------------------------------------------------#
#    add loadBalancer
resource "aws_lb" "load_balancer" {
  name               = "LBtest"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_web.id]
  subnets            = [aws_subnet.first-subnet.id,aws_subnet.scnd-subnet.id]

  //enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "LB_target_groub" {
  name     = "lb-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.hamada_vpc.id
}

resource "aws_lb_target_group_attachment" "LB_target_groub_attachment" {
  target_group_arn = aws_lb_target_group.LB_target_groub.arn
  target_id        = aws_instance.web-server-instance.id
  port             = 5000
}
