📘 Online Boutique -- Recovery Runbook
=====================================

*Last updated: April 2025*

This guide is for engineers, SREs, or on-call staff responsible for ensuring uptime of the Online Boutique microservices app running on GKE Autopilot.

---

## ⚙️ Overview

- **Platform**: Google Kubernetes Engine (GKE Autopilot)
- **Infra-as-code**: Terraform
- **Deployment tool**: GitHub Actions (`.github/workflows/deploy.yml`)
- **App config**: Kustomize (`/kustomize/base`)
- **State bucket**: `online-boutique-tf-state-bkt`

---

* * * * *

🚨 General Principles
---------------------

-   The app is deployed via Terraform from GitHub Actions.

-   Kubernetes cluster is **GKE Autopilot**, so infra is managed by Google.

-   App is deployed via **Kustomize** through Terraform.

-   All services are **stateless** unless Redis is enabled.

* * * * *

🧪 Check if the App is Healthy
------------------------------

From a machine with `kubectl` access:

```
kubectl get pods -A
kubectl get services -A
kubectl describe pod <pod-name>
```

Look for:
-   Any pods in `CrashLoopBackOff`
-   Restarts or failures
-   Unusual logs: `kubectl logs <pod-name>`
-   Pods not in Running or Completed
-   High CPU/memory
-   Frequent restarts



* * * * *

🔄 How to Redeploy Everything
-----------------------------

> Use this if the app is partially down, a service crashes, or you're unsure what's wrong.

### Option 1: Re-run GitHub Actions Workflow

1.  Go to your repo → **Actions tab**

2.  Find the latest Terraform workflow (`deploy.yml`)

3.  Click "Re-run all jobs" → it will:

    -   Re-apply Terraform

    -   Re-deploy Kubernetes manifests

    -   Reset most problems

* * * * *

### Option 2: Redeploy Just the App via CLI

If you're on a machine with `kubectl` access:

`kubectl apply -k ./kustomize/ -n default`

This reapplies all app configs.

* * * * *

🔧 How to Fix Common Issues
---------------------------

### ❌ Frontend is Down

-   Run: `kubectl get pods -l app=frontend`

-   Check: Restart count? Logs? `kubectl logs <frontend-pod>`

-   Fix: Re-run GitHub Actions or `kubectl delete pod <frontend-pod>` to restart it

* * * * *

### ❌ Services CrashLoopBackOff

```
kubectl get pods -n default
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

-   Check for missing env vars, broken configs
-   Reapply: `kubectl apply -k ./kustomize/ -n default`

* * * * *

### ❌ Cart or Checkout Failing

-   Check Redis/Memorystore connection (if used)

-   Look at logs: `kubectl logs <cartservice-pod>`

-   Ensure no secrets or env vars are missing

* * * * *

### ❌ Load spikes / resource issues

-   Look in GCP Monitoring → Check CPU/memory `kubectl top pods -n default`

-   If certain pods are hogging memory:

    -   You can set resource limits in the respective `.yaml` files under `kustomize/base/`
    -   Optionally configure Horizontal Pod Autoscaler (HPA).


* * * * *

### ❌ Terraform fails to apply

-   Check GitHub Actions log output for errors

-   Make sure state bucket `online-boutique-tf-state-bkt` exists and is accessible

-   Run `terraform init` locally if needed to debug

-   Confirm your `GOOGLE_CREDENTIALS` secret is valid JSON

* * * * *

Re-deploy / Recover Entire Deployment
-------------------------------------

### ✅ Option 1: Re-run GitHub Actions

1.  Go to GitHub repo → Actions tab

2.  Find the latest `Terraform` workflow

3.  Click "Re-run all jobs"

### ✅ Option 2: Manual CLI Redeploy

```
gcloud container clusters get-credentials online-boutique --region us-central1
kubectl apply -k ./kustomize/ -n default
```

* * * * *

☁️ GCP CLI Quick Checks
-----------------------

```
# Check cluster status
gcloud container clusters describe online-boutique --region us-central1

# Re-authenticate kubectl
gcloud container clusters get-credentials online-boutique --region us-central1

# Get all pods and status
kubectl get pods -n default

# View logs
kubectl logs <pod-name>

# Describe pod or deployment
kubectl describe pod <pod-name>
kubectl describe deploy <deployment-name>
```

* * * * *

🧯 Emergency: App Down, Can't Fix It
------------------------------------

-   Re-run GitHub Actions workflow

-   Or manually delete all pods (they'll auto-restart):

`kubectl delete pod --all -n default`

* * * * *

🧠 Best Practices
------------------

-   Run `terraform plan` before `terraform apply`

-   Use GCP Monitoring to track CPU, memory, and pod restarts

-   Avoid destroying the GCS state bucket!

* * * * *

📋 Related Files
----------------

-   Terraform: `/terraform/*.tf`

-   Kustomize manifests: `/kustomize/base/*.yaml`

-   GitHub Actions: `.github/workflows/deploy.yml`

* * * * *

🆘 Still stuck?
---------------

-   Re-run the GitHub Actions workflow to reset infrastructure and deployment
-   Manually redeploy using kubectl apply
-   Or ask your cloud support/devops partner (like ChatGPT 😎)

* * * * *

✅ Things That *Don't* Need Constant Watching
--------------------------------------------

| Thing | Why |
| --- | --- |
| Terraform state bucket | Rarely changes unless infra is destroyed |
| Kubernetes nodes | GKE Autopilot handles node issues for you |
| Docker image builds | Not handled in this repo --- app images are prebuilt |

* * * * *

✅ That's It!
------------

You're now fully equipped to:

-   Monitor your system

-   Recover from almost all issues

-   Know when to escalate or roll back

* * * * *