#!/usr/bin/env bash
# Disposable Linux runner; no user's host services or volumes are touched.
set -euo pipefail
cd "$(dirname "$0")"
export MYSQL_ROOT_PASSWORD
MYSQL_ROOT_PASSWORD="$(openssl rand -hex 24)"
if [ "${GITHUB_ACTIONS:-}" = true ]; then echo "::add-mask::$MYSQL_ROOT_PASSWORD"; fi
docker compose up -d --wait --wait-timeout 240
set -x
docker compose ps
docker network ls --filter name=yash-24bcs10164-network
docker compose exec -T frontend wget -qO- http://backend:80
docker compose exec -T backend nc -z -w 3 database 3306
if docker compose exec -T frontend getent hosts database; then
  echo 'Unexpected frontend-to-database DNS access'; exit 1
fi
docker compose exec -T database sh -c 'printf "Yash Agrawal 24bcs10164" > /var/lib/mysql/volume-proof.txt'
docker compose restart database
docker compose exec -T database cat /var/lib/mysql/volume-proof.txt
docker compose down
docker compose up -d --wait --wait-timeout 240
docker compose exec -T database cat /var/lib/mysql/volume-proof.txt
docker compose down -v
bind_dir="$(mktemp -d /tmp/kitledger-bind.XXXXXX)"
printf 'Hello students\n' > "$bind_dir/index.html"
chmod 755 "$bind_dir"
chmod 644 "$bind_dir/index.html"
docker run -d --name yash-24bcs10164-bind -p 127.0.0.1:8181:80 -v "$bind_dir:/usr/share/nginx/html:ro" nginx:stable-alpine
curl --retry 10 --retry-all-errors --fail http://127.0.0.1:8181/
printf 'Hello students - live edit by Yash Agrawal\n' > "$bind_dir/index.html"
curl --fail http://127.0.0.1:8181/ | grep 'live edit'
docker rm -f yash-24bcs10164-bind
rm "$bind_dir/index.html"
rmdir "$bind_dir"
docker run -d --name yash-24bcs10164-host --network host httpd:2.4-alpine
curl --retry 10 --retry-all-errors --fail http://127.0.0.1:80/ | grep 'It works'
docker inspect yash-24bcs10164-host --format '{{.HostConfig.NetworkMode}}'
docker rm -f yash-24bcs10164-host
