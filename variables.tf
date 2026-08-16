variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Prefix applied to all resource names"
  type        = string
  default     = "visitor-counter"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway instead of one per AZ (cost vs HA trade-off)"
  type        = bool
  default     = true
}

# --- ECS ---
variable "container_image" {
  description = "Container image URI to deploy, e.g. ECR repo URL:tag"
  type        = string
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "asg_min_size" {
  type    = number
  default = 1
}

variable "asg_max_size" {
  type    = number
  default = 2
}

variable "asg_desired_capacity" {
  type    = number
  default = 1
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "desired_task_count" {
  type    = number
  default = 1
}

variable "container_environment" {
  description = "Environment variables passed to the container"
  type        = map(string)
  default     = {}
}

# --- ALB ---
variable "health_check_path" {
  type    = string
  default = "/api/health"
}

variable "certificate_arn" {
  description = "ACM cert ARN for HTTPS. Leave blank for HTTP-only (not recommended for prod)."
  type        = string
  default     = ""
}

# --- RDS ---
variable "db_name" {
  type    = string
  default = "visitors"
}

variable "db_username" {
  type      = string
  default   = "dbadmin"
  sensitive = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_multi_az" {
  type    = bool
  default = false
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "common_tags" {
  description = "Tags applied to every resource"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
  }
}
