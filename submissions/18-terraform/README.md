# Session 18: Terraform & Infrastructure as Code

Yash Agrawal · 24bcs10164

Implementation: [Terraform S3 lab](terraform-s3-demo), plus separate research:
[IAM](aws-services/01-iam/README.md), [EC2](aws-services/02-ec2/README.md),
[S3](aws-services/03-s3/README.md), [VPC](aws-services/04-vpc/README.md),
[DynamoDB/RDS](aws-services/05-dynamodb-rds/README.md).

The bucket is uniquely named, private, versioned, owner-enforced and encrypted
with SSE-S3. Terraform init/fmt/validate passed on the Linux CI runner.
AWS execution is omitted at the student's request. No plan/apply/show/output or
destroy was run, and no bucket or cloud evidence is invented.

Reference commands only, not a request to provision in the current scope:
```sh
terraform init
terraform fmt -check
terraform validate
terraform plan -out=lab.tfplan
terraform apply lab.tfplan
terraform show
terraform output
terraform plan -destroy
terraform destroy
terraform state list
```
Keep local tfvars/state/plans private. Emptying a versioned bucket requires
reviewing all its own versions/delete markers; do not touch other buckets.

See [the completion audit](../../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
