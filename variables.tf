variable "my_cidr_block" {
    type = string
    default = "10.77.0.0/16"
}



variable "subnets" {
    type = list
    default = ["10.77.10.0/24","10.77.20.0/24"]
}



variable "NICs" {
    type = list
    default = ["10.77.10.50", "10.77.20.50"]
}


variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."
  default = "ami-0502e817a62226e03"
  validation {
    condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}


variable "what_to_do" {
    type = string
    default = <<-EOF
                #!/bin/bash
                sudo apt update
                sudo apt upgrade -y
                sudo apt update              
                sudo apt install apt-transport-https -y
                sudo apt install ca-certificates -y
                sudo apt install curl -y
                sudo apt install software-properties-common -y
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
                sudo apt update
                sudo apt install docker-ce -y
                sudo docker pull ka22ka10/bitcoin_app
                sudo docker build -t ka22ka10/bitcoin_app .
                sudo docker run -p 5000:5000 -t ka22ka10/bitcoin_app
                EOF
}
