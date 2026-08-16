# AWS ECS + RDS Infrastructure (Terraform)

Highly available, containerized app infrastructure: VPC across 2 AZs, ECS on EC2 behind an ALB, and an RDS PostgreSQL backend — following AWS/Terraform best practices for least-privilege IAM and network isolation.

## Architecture

```
                         Internet
                            |
                      [Internet Gateway]
                            |
        ---------------------------------------
        |                                     |
   Public Subnet AZ-a                  Public Subnet AZ-b
   [ALB] [NAT GW]                      [ALB] [NAT GW]
        |                                     |
        ---------------------------------------
                            |
        ---------------------------------------
        |                                     |
   Private Subnet AZ-a                 Private Subnet AZ-b
   [ECS EC2 instances]                 [ECS EC2 instances]
   [RDS Primary]                       [RDS Standby (Multi-AZ)]
```

- **VPC**: `10.0.0.0/16`, 2 public + 2 private subnets across `us-west-1a`/`us-west-1b`
- **NAT Gateway(s)**: private subnets reach the internet (for pulling images, patches) without being publicly reachable
- **ECS on EC2**: Auto Scaling Group + ECS capacity provider with managed scaling; tasks run in private subnets
- **ALB**: public-facing, terminates traffic in public subnets, forwards to ECS tasks
- **RDS PostgreSQL**: private subnets only, Multi-AZ, automated backups, enhanced monitoring, encrypted storage
- **Security groups**: chained least-privilege — internet → ALB (80/443) → ECS (container port only) → RDS (5432 from ECS only)

## Module layout

```
main.tf / variables.tf / outputs.tf / providers.tf   # root wiring
modules/
  vpc/        # VPC, subnets, IGW, NAT, route tables, flow logs
  security/   # security groups (ALB, ECS, RDS)
  alb/        # load balancer, target group, listeners
  ecs/        # cluster, launch template, ASG, capacity provider, task def, service, autoscaling
  rds/        # subnet group, Postgres instance, Secrets Manager password, monitoring
```

## Prerequisites

- Terraform >= 1.5
- AWS credentials configured (`aws configure` or env vars)
- A container image already pushed somewhere ECS can pull it (e.g. ECR)
- (Optional) An ACM certificate ARN in the same region if you want HTTPS

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: set container_image at minimum

terraform init
terraform plan
terraform apply
```

After apply, the app is reachable at the `alb_dns_name` output. Point your domain's DNS (CNAME/ALIAS) at it.

## Notes & things to adapt before production

1. **Remote state**: uncomment the `backend "s3"` block in `providers.tf` and point it at your own state bucket + lock table — local state isn't safe for team use.
2. **Secrets**: the RDS master password is generated with `random_password` and stored in Secrets Manager (`db_secret_arn` output) — never hardcode it. Your app should read it from Secrets Manager at runtime, not from Terraform variables.
3. **HTTPS**: set `certificate_arn` to enable the HTTPS listener and HTTP→HTTPS redirect; without it, the ALB serves plain HTTP on port 80 only.
4. **Task IAM permissions**: `modules/ecs`'s `task_role` currently only has CloudWatch Logs write access. Add whatever policies your app actually needs (S3, SQS, the DB secret, etc.) — keep it scoped to specific resources, not `*`.
5. **Cost vs HA**: `single_nat_gateway = false` gives one NAT per AZ (recommended for prod HA). Set to `true` in dev/staging to cut NAT costs.
6. **Bastion/DB access**: RDS has no public access and no bastion host wired up. Add an SSM-accessible bastion or a VPN/Session Manager path if you need direct psql access.
7. **Container health check**: the ALB target group checks `/health` by default — make sure your app exposes that route, or change `health_check_path`.
