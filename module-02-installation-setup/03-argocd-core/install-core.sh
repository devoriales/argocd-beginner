#!/usr/bin/env bash
# Install Argo CD Core: the same reconciliation engine without its front door.
#
# Core omits argocd-server (API and UI), argocd-dex-server (SSO, which has no API
# server to delegate to) and argocd-notifications-controller. Four workloads
# instead of seven. Everything that actually performs GitOps is still present.
#
# With no API server, drive it with kubectl, or with `argocd ... --core`. Without
# that flag the CLI tries to reach an API server that is not running and the
# connection error looks like a networking problem.
set -euo pipefail

ARGOCD_VERSION="${ARGOCD_VERSION:-v3.4.5}"
MANIFEST="https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/core-install.yaml"

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts -f "$MANIFEST"

kubectl wait --for=condition=Available --timeout=300s deployment --all -n argocd
kubectl get deploy,statefulset -n argocd
echo
echo "list applications without an API server:"
echo "  argocd app list --core"
