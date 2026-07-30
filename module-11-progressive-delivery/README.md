# Module 11: Progressive Delivery

Runnable artifacts for this module. Lesson prose lives on
[devoriales.com](https://devoriales.com). This folder holds only what you run.

| # | Lesson | Artifacts |
| --- | --- | --- |
| 1 | Where ArgoCD ends and Argo Rollouts begins | _none, conceptual_ |
| 2 | Canary and blue-green concepts (conceptual only) | _none, conceptual_ |
| 3 | Wiring ArgoCD sync with a Rollout resource | `03-wiring-argocd-with-rollouts/` |

`03-wiring-argocd-with-rollouts/` holds the same Rollout twice, under `v1/` and `v2/`,
differing only in the image tag. Pointing the Application at `v1`, then switching its
`source.path` to `v2`, is how you trigger a canary without pushing to this repository.
The desired state still comes from Git either way.

Argo Rollouts is a separate install and its CRDs must exist before any `Rollout` object:

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts --server-side --force-conflicts \
  -f https://github.com/argoproj/argo-rollouts/releases/download/v1.9.1/install.yaml
```

Folders appear here as each lesson is published and verified. A lesson folder
contains only what the course has taught up to that point.
