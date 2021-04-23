terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
  required_version = ">= 0.13"
}

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
                
  EOF
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

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "tutorial"
  ports {
    internal = 80
    external = 80
  }
}

resource "null_resource" "epel" {
    provisioner "local-exec" {
        command = "sudo yum install -y epel-release"
    }
}
resource "null_resource" "nginx" {
    provisioner "local-exec" {
        command = "sudo yum –y install nginx"
    }
}
resource "null_resource" "start" {
    provisioner "local-exec" {
        command = "sudo systemctl start nginx && sudo systemctl enable nginx"
    }
}
output "instance_ips" {
  value = aws_instance.web-server.public_ip
}
