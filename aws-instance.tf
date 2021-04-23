provider "aws" {
  region = "eu-west-1"
  access_key = "${var.aws_api_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_instance" "web-server" {
  ami = "ami-0019f18ee3d4157d3"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.web-server.id ]
  key_name = "logkey"

  user_data = <<-EOF
        #! /bin/bash
        sudo yum install -y epel-release
        sudo yum –y install nginx
        sudo systemctl start nginx
        sudo systemctl enable nginx
 
  EOF
  tags = {
           Name="terraform"
  }
}

resource "aws_security_group" "web-server" {
  name = "web-srv1"
  
  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [ "0.0.0.0/0" ] 
  }
  
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

output "instance_ips" {
  value = aws_instance.web-server.public_ip
}
