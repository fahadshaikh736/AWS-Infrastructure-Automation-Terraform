variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "container_port" {
  description = "Port the ECS task/container listens on"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Port Postgres listens on"
  type        = number
  default     = 5432
}

variable "tags" {
  type    = map(string)
  default = {}
}
