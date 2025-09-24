# Wisecow CI/CD Pipeline

This document explains the **CI/CD workflow** for the Wisecow application, including **Docker image building, pushing, and Kubernetes deployment automation** using GitHub Actions and ArgoCD.

---

## Overview

The Wisecow CI/CD pipeline automates the following tasks:

1. **CI (Continuous Integration)**

   * Build the Docker image for the Wisecow app.
   * Tag the image with the short commit SHA.
   * Push the image to Docker Hub.

2. **CD (Continuous Deployment)**

   * Update Kubernetes deployment manifests with the new image tag.
   * ArgoCD monitors the Git repository and syncs the updated manifests automatically to the cluster.

This ensures a **fully automated workflow** from code push to application deployment.

---

## GitHub Actions Workflow

Workflow file: `.github/workflows/cicd.yaml`

### Trigger

* `push` to `main` branch.
* Manual trigger via `workflow_dispatch`.

### Environment Variables

```yaml
env:
  IMAGE_NAME: ${{ secrets.DOCKER_HUB_USERNAME }}/wisecow
```

* `DOCKER_HUB_USERNAME` is stored as a secret in GitHub.

### Jobs

#### 1. Build & Push Docker Image

**Runs-on:** `ubuntu-latest`

**Steps:**

1. **Checkout repository**

```yaml
uses: actions/checkout@v3
```

2. **Get short SHA for tagging**

```bash
echo "sha=$(git rev-parse --short HEAD)" >> $GITHUB_OUTPUT
```

3. **Login to Docker Hub**

```yaml
uses: docker/login-action@v2
with:
  username: ${{ secrets.DOCKER_HUB_USERNAME }}
  password: ${{ secrets.DOCKER_HUB_PASSWORD }}
```

4. **Build Docker image**

```bash
docker build -t $IMAGE_NAME:${{ steps.vars.outputs.sha }} .
```

5. **Push Docker image**

```bash
docker push $IMAGE_NAME:${{ steps.vars.outputs.sha }}
```

#### 2. Edit Deployment Manifests

**Runs-on:** `ubuntu-latest`
**Needs:** `build-and-push`

**Steps:**

1. **Checkout repository**
2. **Update deployment YAML**

```bash
SHA=${{ needs.build-and-push.outputs.sha }}
sed -i "s|image:.*|image: $IMAGE_NAME:$SHA|" k8s/dep.yaml
```

3. **Commit and push changes**

```bash
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add k8s/dep.yaml
git commit -m "Update deployment image to $IMAGE_NAME:${{ needs.build-and-push.outputs.sha }}" || echo "No changes to commit"
git push
```

---

## Deployment via ArgoCD

* The cluster has **ArgoCD deployed** and monitors the Git repository.
* **Auto-sync is enabled**, so any changes to deployment manifests are automatically applied.
* This ensures that the application is always running the latest Docker image after a successful CI build.

---

## Benefits

* Fully automated CI/CD pipeline from code commit to deployment.
* Versioned Docker images using commit SHA.
* Zero manual intervention for deployments.
* Integration with ArgoCD ensures GitOps-based deployment and visibility.

---

## References

* [GitHub Actions Documentation](https://docs.github.com/en/actions)
* [Docker Hub](https://hub.docker.com/)
* [ArgoCD Documentation](https://argo-cd.readthedocs.io/en/stable/)
