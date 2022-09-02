output "service_alb" {
  value = aws_alb.main
}

output "cluster_name" {
  value = aws_ecs_cluster.app.name
}

output "service_name" {
  value = aws_ecs_service.main.name
}

