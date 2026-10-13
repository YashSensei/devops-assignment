# Session 8: Docker Networking

Yash Agrawal · 24bcs10164

Implementation: [compose.yml](compose.yml), [verify.sh](verify.sh).
```sh
bash session8-docker-networking-volume/verify.sh
```
Frontend joins edge and isolated; backend joins edge and data; MySQL joins only
the internal data network. Frontend can resolve/request the backend; backend can
connect to database:3306; frontend cannot resolve the database. Three networks
do not automatically imply isolation: attachments and published ports determine it.

The disposable Linux runner checks a MySQL volume across restart and Compose
recreation, a read-only Nginx bind mount updated live, and Apache host networking
at port 80. Docker Desktop host networking is not silently equated to Linux host
networking. Overlay networks connect containers across Docker hosts through
encapsulation, typically VXLAN with Swarm coordination; this single-host lab
documents that concept but does not claim a multi-host overlay deployment.

The first added networking run failed because minimal Alpine lacked httpd.
Using the Nginx image fixed the actual missing command.
[Successful corrected run](https://github.com/YashSensei/devops-assignment/actions/runs/38449941808).
Cleanup is restricted to this Compose project and the two explicitly named
host/bind test containers; the lab deletes its own demonstration volume.

See [the completion audit](../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
