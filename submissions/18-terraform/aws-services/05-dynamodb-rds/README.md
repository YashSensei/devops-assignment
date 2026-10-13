# DynamoDB and RDS

DynamoDB is a managed NoSQL key-value/document database. A table contains items,
each with attributes. The partition key determines placement and access;
an optional sort key orders related items in a partition. Access patterns must
guide key and index design. It suits session data, event metadata and predictable
key-based lookups. On-demand and provisioned capacity have different costs;
NoSQL does not mean schema design is unnecessary.

RDS manages relational engines such as PostgreSQL, MySQL, MariaDB, Oracle and
SQL Server (availability depends on region/edition). A DB instance exposes an
engine with tables, constraints, transactions and SQL. Network isolation,
Security Groups, IAM where supported, credentials and encryption protect access.

Automated backups and snapshots provide recovery. Multi-AZ primarily supports
availability/failover; read replicas primarily scale reads and can lag the writer.
These are not interchangeable. Use RDS for relational applications needing
managed backups/operations; use DynamoDB for access patterns fitting its data model.
KitLedger uses PostgreSQL constraints to protect lending rules. Its coursework
database runs in a container; that is not a claim of an RDS deployment.

[RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html) ·
[DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html)
