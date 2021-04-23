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
  user_data = <<-EOF

    Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [users-groups, once]
users:
  - name: root
    ssh-authorized-keys: 
    - PublicKeypair

EOF
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+EHkcujhnlJqi9hK5uEAT/o4xp8cuYtbtgyvZo9diIxhGvOb1ZKSk2ne3+XBH8HJvuOOqmhu0KwnL+tAGF6Q1LCoGjFPZLF+xrwvQeEuE7VCzTRJRvtA6fhrVc8WQPl4Ib1B8LBwDS+/JJRVpiNRpcjUbZrSSDyvmTF6V6FRaJie5AsCYNENXXV+4WgqmqL7cR8S49t/8tGpEVeJMk+HIXpzDzJxJ2U5zpRV9FsHEiTM8KavhvlHEXP5AJqjS/mEfdKBKt7/xwUij7JzU51OccWyBXdF0EBb/K4gyW9h0m8oCrYu44J5SqCfCSYkdES5rEXZrxA5iWIUssFKLcNGzL9ifHO1PC/NMAgOQ+HjAvvAjjHA83ACl9y4SEwaRnEMokhFStoFniWUHZ9E45w6+0YseW60Qno4j2r+MtdyRUPEN/a+WFwSk3KUkzNr5lZ4F1tngAYziib7iVWHgI/D9xH1BgCLYS6JpDf5R1VTjhMa9DFFF2/1+6PeE+c2Yit7FToZfJYTiYDrUigIZdrP+pQlCyjyRlxbfxbIyEs/RDIG+t2LanCp9ZlgY6txWll4RFPgZE1BW/PqXFfrTcNf75VeKKJsysEjJrweWxU6fsGeIJDXikrAMHAc3AGGy1inrPzW9Ww2/zLwvkOn0RBPIW33payVcWhe74S6Shq7WyQ== petar.nikolov@softwaregroup.com"
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

output "instance_ips" {
  value = aws_instance.web-server.public_ip
}
