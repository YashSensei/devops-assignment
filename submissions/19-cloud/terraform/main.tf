data "aws_availability_zones" "available" { state = "available" }
data "aws_ssm_parameter" "ami" {
  count = var.create_compute ? 1 : 0
  name  = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
resource "aws_vpc" "lab" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "lab" { vpc_id = aws_vpc.lab.id }
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }
}
resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}
resource "aws_security_group" "web" {
  name   = "yash-24bcs10164-s19-web"
  vpc_id = aws_vpc.lab.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "web" {
  count                  = var.create_compute ? 1 : 0
  ami                    = data.aws_ssm_parameter.ami[0].value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  metadata_options { http_tokens = "required" }
  root_block_device {
    volume_size = 8
    encrypted   = true
  }
  user_data  = <<-SCRIPT
    #!/bin/bash
    set -eu
    dnf install -y nginx
    printf '<h1>Yash Agrawal - 24bcs10164 - Terraform cloud lab</h1>' > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  SCRIPT
  depends_on = [aws_route_table_association.public]
}
resource "random_id" "suffix" { byte_length = 4 }
resource "aws_s3_bucket" "lab" {
  count         = var.create_compute ? 1 : 0
  bucket        = "yash-24bcs10164-s19-${random_id.suffix.hex}"
  force_destroy = false
}
resource "aws_s3_bucket_public_access_block" "lab" {
  count                   = var.create_compute ? 1 : 0
  bucket                  = aws_s3_bucket.lab[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_server_side_encryption_configuration" "lab" {
  count  = var.create_compute ? 1 : 0
  bucket = aws_s3_bucket.lab[0].id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}
