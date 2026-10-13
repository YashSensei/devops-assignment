output "vpc_id" { value = aws_vpc.lab.id }
output "public_subnet_id" { value = aws_subnet.public.id }
output "web_url" { value = var.create_compute ? "http://${aws_instance.web[0].public_ip}" : null }
output "bucket_name" { value = var.create_compute ? aws_s3_bucket.lab[0].id : null }
