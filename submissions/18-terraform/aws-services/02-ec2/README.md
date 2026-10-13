# EC2: compute

EC2 runs virtual machines. An AMI supplies an operating system and initial
filesystem; an instance type supplies CPU, memory and network capacity.
Choose architecture-compatible software and images. Key pairs support SSH
authentication; Systems Manager can avoid inbound SSH when configured.

Security Groups are stateful allow rules attached to network interfaces.
EBS volumes persist independently of a stopped instance; deletion on termination
depends on the mapping. A private IP is used within the VPC, while a public IP
permits internet addressing only when routing and firewall rules also allow it.
Public IPv4 addresses can incur separate charges.

Lifecycle: pending, running, stopping/stopped, shutting-down/terminated.
Stopping compute does not delete EBS storage or remove every charge. Termination
is not proof that snapshots, load balancers or addresses were cleaned up.
Uses include web servers, build agents, batch jobs and self-managed databases.

[Official EC2 guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)
