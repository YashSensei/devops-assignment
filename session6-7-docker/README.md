# Session 6: Docker Fundamentals

Yash Agrawal · 24bcs10164

All six case-sensitive folders contain original Hello World source and Dockerfiles:
nodejs-app, python-app, java-app, Apache-app, React-app, nginx-app.
```sh
bash session6-7-docker/verify.sh
```
[Actual build/run/HTTP output](../evidence/ci/foundations-38448115326/docker-hello.log).
The same script also checks Session 7. It assigns local host ports 8101-8106
and uses container port 8080 except Apache (80). Each container is named
yash-24bcs10164-hello-N and is removed individually after verification.

The React endpoint test checks the served document, not browser-rendered Hello
World text. The required React Hello World browser screenshot is still pending.
No outputs from another student are used.

See [the completion audit](../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
