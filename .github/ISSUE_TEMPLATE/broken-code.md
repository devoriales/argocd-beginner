---
name: Broken code or command
about: An artifact, command, or manifest in this repo does not work as the lesson describes
title: "[broken] Module NN Lesson NN, short description"
labels: broken-code
---

## Which lesson

- **Module / lesson:** <!-- e.g. Module 2, Lesson 2, Installing Argo CD -->
- **Folder:** <!-- e.g. module-02-installation-setup/02-install-argocd/ -->
- **Lesson URL:** <!-- the devoriales.com page, if relevant -->

## What you ran

<!-- The exact command, copy-pasted. -->

```bash

```

## What happened

<!-- The actual output or error, copy-pasted rather than described. Include enough
     surrounding output to show the context. -->

```

```

## What the lesson said would happen

<!-- Quote or paraphrase the expected result. -->

## Your versions

Please paste real output rather than filling this in from memory, a version mismatch
is the single most common cause, and it is invisible when transcribed by hand.

```bash
argocd version --client --short
k3d version
kubectl version
helm version --short
kustomize version
docker version --format '{{.Server.Version}}'
```

```

```

## Platform

- **OS / arch:** <!-- e.g. macOS 26.4, Apple Silicon (M3) -->
- **Docker runtime:** <!-- Colima 0.8.1 / Docker Desktop / other -->

## Anything else

<!-- Did it work before? Does it fail every time or intermittently? Were there other
     clusters running at the time? -->
