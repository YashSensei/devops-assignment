#!/usr/bin/env bash
set -euxo pipefail
test "${GITHUB_ACTIONS:-}" = true
namespace=kitledger-network-lab
sudo ip netns add "$namespace"
trap 'sudo ip netns delete kitledger-network-lab' EXIT
sudo ip -n "$namespace" link add demo0 type dummy
sudo ip -n "$namespace" addr add 192.0.2.10/24 dev demo0
sudo ip -n "$namespace" link set demo0 up
sudo ip -n "$namespace" link set demo0 mtu 1400
sudo ip -n "$namespace" -s link
sudo ip -n "$namespace" addr
sudo ip -n "$namespace" route
sudo ip -n "$namespace" route add 198.51.100.0/24 via 192.0.2.1 dev demo0
sudo ip -n "$namespace" route get 198.51.100.10
sudo ip -n "$namespace" route replace 198.51.100.0/24 dev demo0
sudo ip -n "$namespace" neigh add 192.0.2.1 lladdr 02:00:00:00:00:01 dev demo0
sudo ip -n "$namespace" neigh
sudo ip -n "$namespace" neigh replace 192.0.2.1 lladdr 02:00:00:00:00:02 dev demo0
sudo ip -n "$namespace" neigh del 192.0.2.1 dev demo0
sudo ip -n "$namespace" maddr
sudo ip -n "$namespace" route del 198.51.100.0/24 dev demo0
sudo ip -n "$namespace" addr del 192.0.2.10/24 dev demo0
sudo ip -n "$namespace" link set demo0 down
