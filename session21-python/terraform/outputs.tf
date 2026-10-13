output "cluster_name" { value = aws_eks_cluster.lab.name }
output "vpc_id" { value = aws_vpc.lab.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.lab.name}"
}
