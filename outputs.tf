output "alb_dns_name" {
  description = "Public DNS name of the load balancer - point your domain here"
  value       = module.alb.alb_dns_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "db_endpoint" {
  value     = module.rds.db_endpoint
  sensitive = true
}

output "db_secret_arn" {
  description = "Secrets Manager ARN holding the DB master credentials"
  value       = module.rds.secret_arn
}
