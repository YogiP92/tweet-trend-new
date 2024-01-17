provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "demo_server" {
    ami = "ami-08fe36427228eddc4"
    instance_type = "t2.micro"
    key_name = "dpp"
  
}