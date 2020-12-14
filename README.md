# bitcoin webpage

Welcome to my simple app, You need a simple knowledge in terraform to understand this.
this app uses terraform to create AWS_VPC and within this VPC there are 2 subnets, in 1 of them there is a web server (aws_ec2 - t2.micro(free tier) ubunto 20.04)
on this server will be installed a container from dockerhub (ka22ka10/bitcoin_app) that i created...
in this container will run nginx and flask application that runs a simple html page which show you real-time price of bitcoin.


# how to run this app:
1)
    u need to edit providerr.tf file that contains:

    provider "aws" {
      region = "eu-central-1"
        access_key = "*****************"
         secret_key = "*****************"
    }

 insert your access key and secret key.
 
 
 2)
 open terminal, go to the directory which contains all the files and write:
 -> terraform init (this will take 30-60 scnds)
 -> terraform apply (this will take 4-5 mnts)
  you will get an IP address (as terraform apply output)
  
  
  3)
  go to any web browser and visit (use the ip-addr from step 2):
  http://ip-addr:5000/
  
  
  4)-------------------------------------------------------------------------------------------------------------------------important
  
  after you finish dont forget:
  -> terraform destroy
