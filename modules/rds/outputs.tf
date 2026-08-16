output "db_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "db_address" {
  value = aws_db_instance.this.address
}

output "db_name" {
  value = aws_db_instance.this.db_name
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret holding the master username/password"
  value       = aws_secretsmanager_secret.db_password.arn
}
