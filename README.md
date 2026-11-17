# Formlabs DevOps home assignment

This repository contains a home assignment code for DevOps applicants for Formlabs.

See all open jobs at https://careers.formlabs.com/


## Task

0. Fork this repo.
1. Create a deployable docker image for the application.
    - Feel free to switch up technologies. For example you can use `buildah` instead of Docker.
2. Create a Kubernetes deployment and service for the application.
    - Just aim for the simplest setup, no ingress deployment is needed. Feel free to use Helm.
    - You can use [Minikube](https://minikube.sigs.k8s.io/docs/start/) or [k3s](https://k3s.io/) or any other Kubernetes distribution you are familiar with.
3. Create automation to build, test and deploy the application when a change happens in git.
    - Feel free to switch up technologies. For example you can use an Ansible playbook or a Jenkins pipeline.
4. Send us the fork where you did your work.

### Notes

- Explain as much as possible in the commit message(s) and/or comments if needed. See more on commit messages [here](https://chris.beams.io/posts/git-commit/).
- It would be great if you'd also write about why you choose a certain technology if there are alternatives to consider.

## Solution summary

| Area | Tool | Key decisions |
|---|---|---|
| Dependencies | pip | Upgraded the 2021-era pins (Flask 3, gunicorn ≥ 23) to clear known CVEs, including HTTP request smuggling in gunicorn < 22. |
| Image | Docker | `python:3.14-slim` base for a smaller patch surface; dependency layer cached apart from app code; runs as non-root UID 10001; served by gunicorn on `:8080` instead of Flask's dev server. |
| Kubernetes | Kustomize | 2-replica Deployment with readiness/liveness probes and resource requests/limits, plus a ClusterIP Service on port 80. Kustomize instead of Helm: one app with no per-environment config gains nothing from templating, and kustomize is built into `kubectl`. |
| CI/CD | GitHub Actions | Runs where the repo lives, so there's no Jenkins server to maintain, and results show up as PR checks. Pipeline: unit tests → build → Trivy scan (fails on fixable CRITICAL, reports HIGH; the current HIGHs are in the base image, not our dependencies) → deploy to a throwaway **kind** cluster → smoke test through the Service. |
| Registry | GHCR | Only pushes to `master` and `v*` tags publish. The image is published last, so only images that passed the scan and the deploy ship. Tags are the commit SHA, or the git tag for releases. The publish job pushes the exact tested image (passed as an artifact), not a rebuild. |

**Run and test locally:** 
```bash
docker build -t helloapp:local .
docker run --rm -p 8080:8080 helloap
docker run --rm helloapp python -m unittest helloapp.test
```

**Not implemented / next steps:** 
1. continuous deployment to a real cluster, preferably GitOps with Argo CD updating the image tag in a per-environment overlay.
2. plan and implement a dedicated healthcheck endpoint in the application.
