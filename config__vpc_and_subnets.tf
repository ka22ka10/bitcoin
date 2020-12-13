#--------------------------------------------------------------------------------------------------------#
#    Create VPC with cidr block (value taken from variables.tf), and add internet gateway
resource "aws_vpc" "hamada_vpc" {
  cidr_block = var.my_cidr_block
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.hamada_vpc.id
}





#--------------------------------------------------------------------------------------------------------#
#    Create Custom Route Table
resource "aws_route_table" "hamada-route-table" {
  vpc_id = aws_vpc.hamada_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "hamada_route_table"
  }
}





#--------------------------------------------------------------------------------------------------------#
#    Create Security Group to allow ports 22,80,443, 5000
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.hamada_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "my container open port"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}






#--------------------------------------------------------------------------------------------------------#
#    Create two Subnets and for each subnet:
#               1) associate with the custom route table
#               2) add network interface with ip address

# subnet 1 :
resource "aws_subnet" "first-subnet" {
  vpc_id            = aws_vpc.hamada_vpc.id
  cidr_block        = var.subnets[0]
  availability_zone = "eu-central-1a" 
  tags = {
    Name = "first-subnet"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.first-subnet.id
  route_table_id = aws_route_table.hamada-route-table.id
}

resource "aws_network_interface" "web-server-nic-1" {
  subnet_id       = aws_subnet.first-subnet.id
  private_ips     = [var.NICs[0]]
  security_groups = [aws_security_group.allow_web.id]
}

# subnet 2 :
resource "aws_subnet" "scnd-subnet" {
  vpc_id            = aws_vpc.hamada_vpc.id
  cidr_block        = var.subnets[1]
  availability_zone = "eu-central-1b"
  tags = {
    Name = "scnd-subnet"
  }
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.scnd-subnet.id
  route_table_id = aws_route_table.hamada-route-table.id
}

resource "aws_network_interface" "web-server-nic-2" {
  subnet_id       = aws_subnet.scnd-subnet.id
  private_ips     = [var.NICs[1]]
  security_groups = [aws_security_group.allow_web.id]
}







#--------------------------------------------------------------------------------------------------------#
#    Assign an elastic IP to the network interface of the first subnet
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic-1.id
  associate_with_private_ip = var.NICs[0]
  depends_on                = [aws_internet_gateway.gw]
}
output "server_public_ip" {
  value = aws_eip.one.public_ip
}


