# S3: object storage

A bucket is a named regional container; an object consists of bytes, a key and
metadata. S3 is object storage, not a normal mounted filesystem. Common uses are
static assets, logs, backups and data lakes.

Storage classes trade access frequency, retrieval delay and cost: Standard for
frequent access, Intelligent-Tiering for changing patterns, infrequent-access
classes for rarely read data, and Glacier classes for archival workloads.
Minimum duration and retrieval fees affect the choice.

Versioning retains earlier object versions and delete markers. Lifecycle rules
can transition storage classes and expire versions; delete markers alone do not
empty a versioned bucket. Encryption at rest may use SSE-S3 or SSE-KMS; KMS has
separate policy and cost implications. Transport should use TLS.

Bucket policies are resource policies. Block Public Access and least-privilege
IAM policies keep this lab private. The Terraform exercise enables versioning,
BucketOwnerEnforced ownership and AES256 encryption; no public ACL is needed.
Destroying a nonempty protected bucket requires reviewing its exact contents
and versions first, rather than broadly enabling destructive cleanup.

[Official S3 guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html)
