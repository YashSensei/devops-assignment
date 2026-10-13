# IAM: identity and governance

IAM determines who can do what on which AWS resource. A user is a long-lived
identity; a group assigns the same policies to several users. A role supplies
temporary permissions to a trusted principal such as a workload, federated
student session or GitHub OIDC identity. Groups cannot be assumed like roles.

Policies contain allow/deny statements with actions, resources and optional
conditions. An explicit deny overrides an allow; permission boundaries and
organization policies can limit an otherwise allowed action. Authentication
proves identity; authorization evaluates permissions.

Least privilege for this coursework means permissions scoped to the lab, not
administrator credentials embedded in code. Use federation/SSO and short-lived
roles, MFA, root-account protection, audit logs and regular access review.
Do not publish keys or place them in Terraform variables. Example uses: EC2
workload role reading one S3 bucket; EKS CSI role managing tagged lab volumes;
a CI role trusted only for the intended repository/environment.

[Official IAM documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)
