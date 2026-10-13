#!/usr/bin/env bash
set -euxo pipefail
cd "$(dirname "$0")"
apps=(nodejs-app python-app java-app Apache-app React-app nginx-app multi-stage-dockerfile)
for i in "${!apps[@]}"; do
  app="${apps[$i]}"
  port=$((8101+i))
  inner=8080
  [ "$app" != Apache-app ] || inner=80
  [ "$app" != multi-stage-dockerfile ] || port=8080
  name="yash-24bcs10164-hello-$i"
  docker build -t "$name:lab" "$app"
  docker run -d --name "$name" -p "127.0.0.1:$port:$inner" "$name:lab"
  ready=false
  for attempt in $(seq 1 30); do
    if curl -fsS "http://127.0.0.1:$port/" > "/tmp/$name.html"; then ready=true; break; fi
    sleep 2
  done
  docker ps --filter "name=$name"
  docker logs "$name"
  cat "/tmp/$name.html"
  test "$ready" = true
  if [ "$app" = React-app ]; then
    grep -q '<div id="root">' "/tmp/$name.html"
    # React rendering requires the separately recorded browser exercise.
  elif [ "$app" = multi-stage-dockerfile ]; then
    grep -q 'Hello World from Docker multi-stage build' "/tmp/$name.html"
  else
    grep -q 'Hello World' "/tmp/$name.html"
  fi
  docker rm -f "$name"
done
