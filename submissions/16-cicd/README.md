# Session 16: CI/CD & GitHub Actions

Yash Agrawal · 24bcs10164

The [calculator](app/calculator.py), [tests](tests/test_calculator.py), and
[Dockerfile](Dockerfile) implement the assigned small build/test example.
The executable root [KitLedger workflow](../../.github/workflows/kitledger.yml)
also supplies frontend artifacts, image publishing and real Kubernetes delivery.

A workflow defines triggers/jobs; jobs execute on runners; steps run commands or
Actions. needs enforces job dependencies. Secrets supply sensitive runtime
configuration, while artifacts preserve outputs like test reports and static
builds. CI validates changes; continuous delivery makes a tested build available;
continuous deployment applies it to a target automatically.

The quality job runs the calculator tests as well as the 23 capstone tests.
[Green run](https://github.com/YashSensei/devops-assignment/actions/runs/38448892637).
A separate container execution/artifact for the calculator itself is not yet
claimed; the capstone Docker/CD execution has its own evidence.

See [the completion audit](../../ASSIGNMENT-COMPLETION.md) for current execution and screenshot status.
