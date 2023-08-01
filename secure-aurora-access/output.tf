output "aurora_endpoint" {
  value = aws_rds_cluster.aurora_cluster.endpoint
}

output "bastion_instance_id" {
  value = aws_instance.bastion.id
}
