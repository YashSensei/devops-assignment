# Session 7: Docker Images

Yash Agrawal · 24bcs10164

[Dockerfile](Dockerfile) validates JavaScript in a build stage and copies the
server into a non-root Node runtime. This is an original implementation of the
instructor's required response.
```sh
docker build -t yash-24bcs10164-multistage:lab session6-7-docker/multi-stage-dockerfile
docker run --name yash-24bcs10164-multistage -p 127.0.0.1:8080:8080 yash-24bcs10164-multistage:lab
curl http://127.0.0.1:8080
docker ps --filter name=yash-24bcs10164-multistage
```
The automated [seven-image verifier](../verify.sh) records the exact
**Hello World from Docker multi-stage build** response and docker ps at port 8080.
Node, Python and Java are independently built/run as required.
Remove only the named lab container after inspection.

See [the completion audit](../../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
