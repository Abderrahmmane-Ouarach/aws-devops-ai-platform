# AWS DevOps Platform: URL Shortener with CI/CD

A small URL shortener used to build a complete DevOps workflow on AWS: Terraform infrastructure, a Jenkins pipeline that deploys a Docker image on every push, managed PostgreSQL and Redis in private subnets, and an LLM that explains failed builds.

![The URL Shortener web UI](docs/img/01-app-ui.png)

**Stack:** Node.js/Express, PostgreSQL (RDS), Redis (ElastiCache, cache-aside), Docker, Terraform, Jenkins, ECR, a free-tier LLM API.

## Architecture
 
![Architecture: Jenkins and the app in a public subnet, PostgreSQL and Redis in private subnets, ECR as the image registry](docs/img/00-architecture.png)
 
*One VPC in eu-west-3. Only the two EC2 instances sit in the public subnet; the database and the cache are in private subnets.*

## CI/CD

`git push` → Jenkins polls GitHub → build image → push to ECR (Git SHA tag + `latest`) → SSH deploy to the app instance over its private IP → `/health` check.

![Jenkins pipeline, all stages green](docs/img/02-jenkins-pipeline.png)

![ECR images tagged by commit SHA](docs/img/03-ecr-images.png)

## AI-assisted failure analysis

When a build fails, `analyze_failure.py` masks account IDs and IPs in the log tail, sends it to a free-tier LLM and prints the probable cause and a fix. It never blocks the build, treats the log as untrusted input, and only displays its output.

![AI diagnosis after a deliberately failing stage](docs/img/04-ai-failure-diagnosis.png)

## Infrastructure

Everything is created with Terraform.

- RDS and Redis sit in private subnets and accept traffic only from the app's Security Group.
- One IAM role per instance and no static AWS keys. Jenkins can push only to this ECR repository.
- SSH and the Jenkins UI are limited to my IP.
- The database password lives only in a sensitive Terraform variable and on the app host, never in the repo or in Jenkins.

![VPC resource map](docs/img/05-vpc-resource-map.png)

![Resources managed by Terraform](docs/img/06-terraform-state.png)

## Run it

Locally:

```bash
cp app/.env.example app/.env
docker compose up -d --build
```

On AWS: create `infra/terraform/terraform.tfvars` with `my_ip` and `db_password`, then:

```bash
cd infra/terraform
terraform init && terraform apply
```

## Limitations and next steps

- Prometheus and Grafana are in progress.
- The app host setup and database migrations are manual; they should move to `user_data` or Ansible and a pipeline step.
- Plain HTTP on port 3000; an ALB with an ACM certificate would add TLS.
- Terraform state is local; it should move to S3 with locking.
- The database connection is encrypted but the server certificate is not verified.

RDS, ElastiCache and the EC2 instances bill hourly, so I run `terraform destroy` when idle.

Cloud & DevOps engineering student at INPT, Rabat. [GitHub](https://github.com/Abderrahmmane-Ouarach)
