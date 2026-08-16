variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "health_check_path" {
  type    = string
  default = "/health"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener. Leave empty to skip HTTPS."
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
