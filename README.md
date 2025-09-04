```markdown
# 3-Tier Voting App on AKS with Azure DevOps, Docker & Argo CD

## Overview
This project deploys a classic **three-tier voting application** to **Azure Kubernetes Service (AKS)** using:
- **Docker** images built in **Azure DevOps** pipelines
- **Azure Container Registry (ACR)** for image storage
- **Argo CD** for GitOps-based, declarative delivery

The three app services are:
- **vote** – user-facing web UI where votes are cast  
- **worker** – background processor that handles queued votes and updates state  
- **result** – dashboard UI that displays current tallies  

> Backing data services (e.g., queue/database) are deployed separately; the files provided here focus on the three application services plus Argo CD setup.

---

## Architecture (high-level)

```

Developer Commit ─┐
├─> Azure DevOps Pipelines ──> Docker build & push ──> ACR
Git (manifests) ──┘                                                │
▼
Argo CD (AKS)
│
▼
Deployments & Services
(vote • worker • result)

```

---

## CI: Azure DevOps Pipelines (per microservice)

Each microservice has its own pipeline that **triggers on changes** to its subfolder, **builds** a Docker image, and **pushes** it to ACR.

### Common behavior
- Uses `Docker@2` to build and push
- Tags images with a pipeline tag (typically `$(Build.BuildId)`)
- Publishes to ACR via a **registry service connection**

### `vote` pipeline
- **Trigger:** changes under `vote/`
- **Repository:** `votingapp/vote`
- **Extras:** runs a `ShellScript@2` step (`vote/updateK8sManifests.sh`) to **bump the image tag** in your Kubernetes manifests.  
  This creates a Git change that Argo CD will pick up and sync to the cluster.

### `worker` pipeline
- **Trigger:** changes under `worker/`
- **Repository:** `votingapp/worker`
- Builds & pushes image to ACR. (Add the same manifest-update step as `vote` or use an image automation tool to auto-bump tags.)

### `result` pipeline
- **Trigger:** changes under `result/`
- **Repository:** `votingapp/result`
- Builds & pushes image to ACR. (Likewise, add a manifest-update step or image automation.)

---

## CD: GitOps with Argo CD

### Installation & Exposure
An install script:
- Creates the `argocd` namespace
- Applies the official Argo CD manifests
- Waits for components to become **Ready**
- Exposes the **argocd-server** service (NodePort in the script) and logs in via the Argo CD CLI

> You can optionally patch the `argocd-server` Service to `LoadBalancer` for a cloud IP, or use port-forwarding during development.

### Sync Model
- Argo CD points at the **Git repo** that stores your Kubernetes manifests.
- When the `vote` pipeline updates the image tag (or you merge any manifest change), Argo CD **detects drift** and **syncs** the desired state to AKS.
- For `worker` and `result`, add a similar tag-bump step or enable **Argo CD Image Updater** so they roll automatically on new images.

---

## Kubernetes (AKS) Runtime

- Each service (`vote`, `worker`, `result`) is packaged as a **Deployment** and exposed via a **Service**.
- Pods **pull images from ACR** using your registry connection.
- Ensure AKS has pull rights to ACR (AKS-ACR integration or an `imagePullSecret` in the target namespace).

---

## End-to-End Flow

1. **Code change** in `vote/`, `worker/`, or `result/`.
2. **Azure DevOps** builds and **pushes** a versioned Docker image to **ACR**.
3. (**vote** only, as provided) Pipeline **updates the manifest tag** in Git.
4. **Argo CD** detects the Git change and **syncs** AKS to the new desired state.
5. **AKS** performs a rolling update; new Pods pull the new image from ACR.

---

## Suggested Next Steps

- Add the **manifest update** step to `worker` and `result` pipelines (mirroring `vote`) _or_ enable **Argo CD Image Updater**.
- Standardize `$(tag)` to `$(Build.BuildId)` for immutable, traceable releases.
- Consider switching `argocd-server` to a `LoadBalancer` Service type in AKS for simpler access in non-prod environments.

---

## Troubleshooting Tips

- **ImagePullBackOff**: confirm the exact image **name:tag** in the manifest exists in ACR; verify AKS has **pull permissions**.
- **Argo CD not syncing**: ensure your Argo CD Application points to the correct **repo/branch/path**; check `Sync` policy (auto vs. manual).
- **Access to Argo CD UI**: verify how `argocd-server` is exposed (NodePort, LoadBalancer, or port-forward) and that you’re using the right URL/port.
```

