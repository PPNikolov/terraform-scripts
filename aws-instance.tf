provider "aws" {
  region = "us-west-1"
  key = "${var.aws_api_key}"
  secret = "${var.aws_secret_key}"
}

resource "aws_instance" "web-server" {
  ami = "ami-0019f18ee3d4157d3"
  instance_type = "t2.micro"
}

output "instance_ips" {
  value = aws_instance.tfvm.public_ip
}
