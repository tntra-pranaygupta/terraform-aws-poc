# 🚀 Terraform AWS POC

> A production-style Infrastructure as Code project built with Terraform on AWS — covering networking, compute, high availability, remote state, CI/CD, and Docker.

[![Terraform](https://img.shields.io/badge/Terraform-v1.6+-7B42BC?style=flat-square&logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=flat-square&logo=amazon-aws)](https://aws.amazon.com/)
[![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?style=flat-square&logo=github-actions)](https://github.com/features/actions)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?style=flat-square&logo=docker)](https://www.docker.com/)

---

## ⚡ What This Project Covers

| Phase | Topic | Key Concepts |
|-------|-------|--------------|
| 1 | Core Infrastructure | VPC, Subnets, IGW, Route Tables, Security Groups, EC2, Nginx |
| 2 | Reusable Modules | `modules/`, `environments/`, `tfvars`, input/output wiring |
| 3 | Remote Backend | S3 state storage, DynamoDB locking, state management |
| 4 | High Availability | ALB, Auto Scaling Group, Launch Template, CloudWatch alarms |
| 5 | CI/CD Pipeline | GitHub Actions: fmt → validate → plan → apply |
| 6 | Docker on EC2 | Docker install via `user_data`, containerized Nginx |

---

## 🛠 Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured (`aws configure`)
- AWS IAM user with `AdministratorAccess`
- An EC2 Key Pair created in your target AWS region
- Git + GitHub account

---

## 🚀 Quick Start

### 1. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/terraform-aws-poc.git
cd terraform-aws-poc
```

### 2. Deploy the remote backend (do this once)

```bash
cd backend-setup
terraform init
terraform apply
# Note the S3 bucket name from the output
```

### 3. Configure the dev environment

Edit `environments/dev/backend.tf` — replace the bucket name with your output from step 2.

Edit `environments/dev/terraform.tfvars` — set your `key_pair_name` and verify the `ami_id` for your region.

### 4. Deploy

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### 5. Access your deployment

```bash
terraform output website_url   # open in browser
terraform output ssh_command   # SSH into the instance
```

---

## ⚙️ Configuration

Key variables in `environments/dev/terraform.tfvars`:

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | AWS region |
| `instance_type` | `t3.micro` | EC2 size (free tier) |
| `ami_id` | `ami-0440d3b780d96b29d` | Amazon Linux 2023 (us-east-1) |
| `key_pair_name` | `terraform-poc-key` | Your EC2 key pair name |
| `availability_zones` | `["us-east-1a", "us-east-1b"]` | Multi-AZ deployment |

> **AMI Note:** AMI IDs are region-specific. If you change `aws_region`, find the correct AMI:
> ```bash
> aws ec2 describe-images --owners amazon \
>   --filters "Name=name,Values=al2023-ami-*" \
>   --query 'Images[0].ImageId' --region YOUR_REGION
> ```

---

## 🔁 CI/CD Pipeline

The GitHub Actions workflow runs on every push and pull request:

| Trigger | Jobs |
|---------|------|
| Pull Request | `fmt` → `validate` → `plan` (plan posted as PR comment) |
| Merge to `main` | `fmt` → `validate` → `apply` |

### Setup

Add these secrets to your GitHub repo (`Settings → Secrets → Actions`): 

1) AWS_ACCESS_KEY_ID
2) AWS_SECRET_ACCESS_KEY

---

## 🧹 Cleanup

Always destroy resources when done to avoid AWS charges:

```bash
# Destroy dev environment
cd environments/dev
terraform destroy

# Destroy backend (remove prevent_destroy lifecycle block first)
cd ../../backend-setup
terraform destroy
```

---

## 📌 Key Terraform Concepts Demonstrated

- **Providers & version pinning** — `required_providers`, `~>` constraint
- **Variables & outputs** — typed inputs, validation blocks, output references
- **`count` meta-argument** — multi-AZ subnet creation from a list
- **Module composition** — output of one module fed as input to another
- **Remote state** — S3 backend with DynamoDB locking
- **`terraform import`** — bring existing resources under Terraform management
- **`user_data`** — automated EC2 bootstrapping without SSH
- **Lifecycle rules** — `create_before_destroy`, `prevent_destroy`
- **Auto Scaling** — CloudWatch alarm → scaling policy → ASG

---