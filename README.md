# Argo CD for Beginners: course artifacts

Runnable artifacts for the **Argo CD beginner course** on
**[devoriales.com](https://devoriales.com)**.

This repository is a companion to the course, not a replacement for it. The lessons -
the explanation, the reasoning, the screenshots, live on devoriales.com. What lives
here is only the code you actually run: manifests, Helm values, Kustomize overlays,
cluster configs, and scripts. Clone it and follow along rather than copy-pasting from
your browser.

## Who this is for

You are comfortable with `kubectl`, basic YAML, and containers, and you are new to
**Argo CD specifically**, not new to Kubernetes. Git and general CD concepts are
assumed familiar. The course does not re-teach Kubernetes fundamentals or Git basics.

## Pinned versions

Every artifact here was executed against exactly these versions. They are not
"minimum" or "recommended" versions, they are what was tested. If you run something
else and behavior differs, this table is the first thing to check.

| Component | Version |
| --- | --- |
| Argo CD | **v3.4.5** |
| k3d | **v5.9.0** |
| k3s image | **`rancher/k3s:v1.35.6-k3s1`** |
| Kubernetes (server) | **v1.35.6+k3s1** |
| `kubectl` (client) | **v1.35.7** |
| Helm | **v3.19.4** |
| Kustomize | **v5.8.1** |
| Docker | **27.4.1** |

Validated on macOS (Apple Silicon) with Colima. A Linux x86_64 validation pass is
tracked separately; where a step differs by platform, the lesson says so explicitly.

Two of these pins are less obvious than they look:

- **Kubernetes v1.35.6** is chosen because Argo CD 3.4 is tested against v1.32–v1.35.
  Older minors like 1.31 are both EOL upstream and outside that tested matrix.
- **Helm v3.19.4 and Kustomize v5.8.1** match the versions baked into the Argo CD
  3.4.5 repo-server image. Argo CD renders your charts and overlays server-side with
  *its own* binaries, not yours, so if your local Helm differs, `helm template` on
  your laptop can legitimately produce different output than what Argo CD applies.
  Matching them removes that surprise. You can always check what your cluster uses:

  ```bash
  kubectl exec -n argocd deploy/argocd-repo-server -- helm version --short
  kubectl exec -n argocd deploy/argocd-repo-server -- kustomize version
  ```

## Getting started

```bash
git clone https://github.com/devoriales/argocd-beginner.git
cd argocd-beginner
```

Then start with **Module 2, Lesson 1** on devoriales.com, which walks through creating
the cluster from the config in this repo:

```bash
k3d cluster create --config module-02-installation-setup/01-k3d-local-environment/k3d-cluster-config.yaml
```

That lesson stops at "cluster is up and reachable", Argo CD itself is installed in the
next lesson.

### If cluster creation fails

The most common failure on macOS is an agent node stuck restarting, with `k3d`
reporting only "failed to get ready". The real cause is usually the host's inotify
instance limit, which the default of 128 exhausts once you have more than about one
multi-node cluster running. The actual error appears only in the node's container log:

```bash
docker logs k3d-argocd-101-agent-0 2>&1 | grep "too many open files"
```

Raise it inside your Docker VM (Colima shown):

```bash
colima ssh -- sudo sh -c 'echo "fs.inotify.max_user_instances = 1024" \
  > /etc/sysctl.d/99-k3d-inotify.conf && sysctl -p /etc/sysctl.d/99-k3d-inotify.conf'
```

The second most common failure is pods being evicted in a loop because the Docker VM
disk is nearly full. Argo CD runs seven components; keep a few GB free and check
`kubectl get nodes` for `DiskPressure` after installing.

The third is the API server briefly going away:

```
Unable to connect to the server: net/http: TLS handshake timeout
```

On a four CPU VM this is normal and self-correcting. It happened three times while this
course was being built, always during a burst of work (just after creating the cluster,
just after installing Argo CD, or during a sync that reconciles several applications),
and always cleared within a few minutes.

The cause is CPU saturation, not memory, so `free` will show nothing wrong. Check load
average instead:

```bash
colima ssh -- uptime      # load average above ~20 on 4 CPUs means wait, not debug
```

`install.sh` already waits and retries around this. For ad hoc `kubectl` commands, wait a
minute and run it again. Six to eight CPUs removes the pauses if your machine can spare
them.

## Repository layout

One folder per module, matching the course's module numbering. Inside a module, one
folder per lesson **that has runnable artifacts**, conceptual lessons have none, and
Module 1 is conceptual throughout, so it has no folder here.

Each lesson folder contains only what the course has taught up to that point. Nothing
forward-references a later concept.

```
module-02-installation-setup/
  01-k3d-local-environment/
    k3d-cluster-config.yaml
module-03-core-concepts/
...
module-12-capstone/          # full app-of-apps + ApplicationSet reference solution
```

Folders appear as each lesson is published and verified, so the tree fills in over
time rather than shipping empty placeholders.

## Found something broken?

Everything here is executed before publication, but environments drift and upstream
images change. If an artifact doesn't work, please
[open an issue](https://github.com/devoriales/argocd-beginner/issues/new?template=broken-code.md)
and include your versions from the table above, that is almost always the fastest
path to a diagnosis.

## License

MIT, see [LICENSE](LICENSE).
