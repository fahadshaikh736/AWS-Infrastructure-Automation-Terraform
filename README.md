AWS Infrastructure Automation using Terraform

A highly available, containerized visitor-counter application deployed on AWS entirely 
through Terraform — a 3-tier VPC, ECS-on-EC2 compute,
 an Application Load Balancer, and a PostgreSQL RDS backend — with 
a fully automated CI/CD pipeline via GitHub Actions

                              Internet
                                 |
                        [Internet Gateway]
                                 |
        -------------------------------------------------
        |                                               |
  Public Subnet (ap-south-1a)              Public Subnet (ap-south-1b)
  [ALB]  [NAT Gateway]                     [ALB]
        |                                               |
        -------------------------------------------------
                                 |
        -------------------------------------------------
        |                                               |
  Private Subnet (ap-south-1a)             Private Subnet (ap-south-1b)
  [ECS EC2 instance]                       [ECS EC2 instance]
        |                                               |
        -------------------------------------------------
                                 |
        -------------------------------------------------
        |                                               |
  Secure Subnet (ap-south-1a)              Secure Subnet (ap-south-1b)
  [RDS PostgreSQL]                         (no IGW / NAT route)
        -------------------------------------------------



VPC: 10.0.0.0/16 across ap-south-1a / ap-south-1b, with public, private, and secure subnet tiers
NAT Gateway: lets private-subnet instances reach the internet (image pulls, updates) without being publicly reachable
ECS on EC2: Auto Scaling Group + ECS capacity provider; the application container runs in the private subnet with no public IP, reachable only via AWS Systems Manager (no SSH / port 22)
ALB: public-facing, forwards to the ECS service's target group
RDS PostgreSQL 16.9: secure subnet only, SSL-enforced connections, encrypted storage, automated backups, master password generated and stored in Secrets Manager (never hardcoded)
Security groups: chained least-privilege — internet → ALB (port 80) → ECS (container port only) → RDS (5432 from ECS only)
CloudWatch: VPC flow logs, ECS container logs, and a dashboard tracking CPU/memory utilization, ALB request count, and live application logs
CI/CD: GitHub Actions pipeline — init/validate/fmt/plan on every push and pull request, automatic apply on merge to main


Application

A small Node.js/Express backend (server.js) connects to RDS via pg, with two endpoints:

GET /api/health — health check used by the ALB target group
GET /api/visit — increments and returns a persistent visit counter stored in Postgres

The database connection uses ssl: { rejectUnauthorized: false }, required because this RDS instance enforces SSL on all connections.


Module Layout
main.tf / variables.tf / outputs.tf / providers.tf   # root wiring
bootstrap/           # one-time S3 + DynamoDB backend setup
environments/dev/    # per-environment entry point
modules/
  vpc/        # VPC, subnets, IGW, NAT, route tables, flow logs
  security/   # security groups (ALB, ECS, RDS)
  alb/        # load balancer, target group, listener
  ecs/        # cluster, launch template, ASG, task definition, service, autoscaling, dashboard
  rds/        # subnet group, Postgres instance, Secrets Manager password, monitoring
.github/workflows/terraform.yml   # CI/CD pipeline


Prerequisites
Terraform >= 1.5
AWS credentials configured (aws configure)
Docker (for building/pushing the application image)
An ECR repository for the application image


Usage
# One-time: create the remote state backend
cd bootstrap
terraform init && terraform apply

# Deploy the infrastructure
cd ..
cp terraform.tfvars.example terraform.tfvars   # edit as needed
terraform init
terraform plan
terraform apply


After apply, the app is reachable at the alb_dns_name output:
http://<alb_dns_name>/api/health
http://<alb_dns_name>/api/visit



CI/CD Pipeline

GitHub Actions (.github/workflows/terraform.yml) runs:

On push to any branch (except main): terraform init, validate, fmt -check, plan, plus a Checkov security scan
On pull request to main: the same checks, so reviewers can see the planned changes
On push to main (i.e. after merge): terraform apply -auto-approve

AWS credentials are provided via GitHub repository secrets (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY) for a dedicated IAM user scoped to this pipeline.


Notes on design decisions
Route 53 was intentionally omitted — no domain was available for this project; the ALB's own DNS name serves the same purpose.
RDS engine version is pinned to 16.9 — not every Postgres minor version is available in every AWS region, so this was confirmed against
 aws rds describe-db-engine-versions before pinning.
Container port is 3000 (not 80) — matches the Node.js application's actual listening port; the ALB target group and ECS task definition are both configured accordingly.
The ECS target group uses create_before_destroy — avoids a ResourceInUse error when Terraform needs to replace the target group
 (e.g. after a port change) while a listener still references it.
IAM roles for this project use AdministratorAccess for simplicity in a learning context. In a production setting, this would be scoped down
 to only the specific EC2/RDS/S3/DynamoDB/ECS/ELB permissions Terraform actually needs.