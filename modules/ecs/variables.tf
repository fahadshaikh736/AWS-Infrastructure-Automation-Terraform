variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_sg_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "container_image" {
  description = "Container image to run, e.g. 123456789.dkr.ecr.us-west-1.amazonaws.com/app:latest"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "asg_min_size" {
  type    = number
  default = 2
}

variable "asg_max_size" {
  type    = number
  default = 6
}

variable "asg_desired_capacity" {
  type    = number
  default = 2
}

variable "task_cpu" {
  type    = number
  default = 512
}

variable "task_memory" {
  type    = number
  default = 1024
}

variable "desired_task_count" {
  type    = number
  default = 2
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "environment" {
  description = "Environment variables to inject into the container"
  type        = map(string)
  default     = {}
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN holding the DB username/password JSON - injected as DB_USER/DB_PASSWORD"
  type        = string
  default     = ""
}

variable "create_db_secret_access" {
  description = "Whether to grant the task execution role access to db_secret_arn. Set explicitly by the caller since db_secret_arn's value isn't known until apply."
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB, for CloudWatch metrics"
  type        = string
}