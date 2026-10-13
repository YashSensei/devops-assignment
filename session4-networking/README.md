# Session 4: Networking

Yash Agrawal · 24bcs10164

Implementation: [network.sh](network.sh), [isolated-ip.sh](isolated-ip.sh).
```sh
bash session4-networking/network.sh
bash session4-networking/isolated-ip.sh
```
ip address shows assigned interfaces/addresses; ip route explains forwarding;
resolv.conf/getent inspect DNS; ss lists listening sockets; ping tests ICMP;
curl tests HTTP/TLS; traceroute reveals responding hops. A failed ICMP or
traceroute probe does not establish an Internet outage when HTTPS works.

The ip mutation exercise uses only a disposable Linux network namespace and
dummy interface: address/link/MTU changes, route add/replace/delete, neighbor
entries and multicast inspection do not alter the host's active interfaces.
[Recorded network observations](../evidence/ci/foundations-38448115326/network.log).
Each command records its own exit code; the observation script is not an assertion
that every external destination responded. Hardware LED/driver operations and
unauthorized scanning of outside hosts are not performed.

See [the completion audit](../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
