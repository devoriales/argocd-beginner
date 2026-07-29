# Module 2 — Installation & First Setup

Runnable artifacts for this module. Lesson prose lives on
[devoriales.com](https://devoriales.com) — this folder holds only what you run.

| # | Lesson | Artifacts |
| --- | --- | --- |
| 1 | Setting up your local environment with k3d | `01-*/` |
| 2 | Installing ArgoCD on the k3d cluster (standard install) | `02-*/` |
| 3 | ArgoCD Core (headless, no UI/SSO) — when to use which | `03-*/` |
| 4 | Accessing the UI and CLI (port-forward, LoadBalancer, Ingress) | `04-*/` |
| 5 | Initial admin login, password rotation, securing the bootstrap secret | _none — conceptual_ |
| 6 | Installing the argocd CLI on macOS (Apple Silicon) | _none — conceptual_ |

Folders appear here as each lesson is published and verified. A lesson folder
contains only what the course has taught up to that point.

## Prefer to run this in a browser?

The install, access and admin-password parts of this module are also a hands-on lab on Killercoda, with a real Kubernetes cluster and no local setup:

**[Argo CD: Install It, and Understand Why the Obvious Way Fails](https://killercoda.com/devoriales/course/argocd/scenario-1-install-and-access)**

The local k3d path in this folder is still the one the course teaches, because it is the environment you keep for the rest of the modules.
