# AWS execution contract

Status: CI init/fmt/validate passed; AWS plan/apply/destroy not executed at the
student's request. Below is reference guidance, not an active provisioning plan.
The example account, region, version and CIDR are deliberately non-deployable examples.

Before apply: authenticate through AWS CLI/SSO; run `aws sts get-caller-identity`;
confirm profile/account/region, current supported EKS version and instance availability.
Review the exact plan and a separate cost/runtime budget for this lab. Arrange
authenticated AWS Console VPC/EKS screenshots before applying. Approval for a
different lab is not approval for EKS.

Architecture: one VPC, two public subnets in different AZs, Internet Gateway,
route table, EKS control plane, one managed node group (one t3.medium by default),
IAM roles, Pod Identity and EBS CSI add-ons. No NAT gateway is declared. Public
node networking is a short-lived coursework cost tradeoff; the API endpoint
restricts public access to approved CIDRs. A Kubernetes LoadBalancer costs extra
and must be explicitly included in the approved plan. StorageClass is supplied
in ../k8s/ebs-storageclass.yaml; use database.storageClass=kitledger-gp3.

Commands after approvals:
```sh
terraform init
terraform fmt -check
terraform validate
terraform plan -out=lab.tfplan
terraform apply lab.tfplan
terraform show
terraform output
```

Keep local state and plan private; do not commit either. Plans contain sensitive
values. Provider lockfiles belong in Git. This app has no authentication and is
a controlled coursework demo: limit ingress to the approved audience.

Before destroy: capture screenshots and presentation, suspend Argo reconciliation,
remove only this lab's Kubernetes LoadBalancers and PVCs, verify AWS LB/EBS deletion,
then review `terraform plan -destroy` and run `terraform destroy`.
Verify `terraform state list` is empty and audit tagged EKS, EC2, EBS, NAT,
EIP, LB, S3 and any other resources. Do not delete unrelated resources. Billing
can lag cleanup. No cleanup success is claimed before an actual apply/destroy.
