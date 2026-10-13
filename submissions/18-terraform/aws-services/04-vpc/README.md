# VPC: networking

A VPC is an isolated virtual network with an address range written as CIDR,
for example 10.20.0.0/16. Subnets divide it into smaller ranges in individual
Availability Zones. Route tables choose destinations by longest prefix match.

A public subnet has a route to an Internet Gateway. An instance still needs a
public address and suitable Security Group/Network ACL rules to be reachable.
A private subnet has no direct Internet Gateway default route. A NAT gateway
can provide outbound IPv4 access for private instances, with hourly and
data-processing costs; it does not accept unsolicited inbound internet traffic.

Security Groups are stateful allow rules on interfaces. Network ACLs are
stateless subnet rules with numbered allow/deny entries; both request and return
traffic must be permitted. They solve different filtering problems.

This coursework uses separate VPCs and project tags. No shared network, account
default VPC, or unrelated route table is a cleanup target.
[Official VPC guide](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
