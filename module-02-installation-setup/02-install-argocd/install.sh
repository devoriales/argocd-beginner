#!/usr/bin/env bash
# Install Argo CD 3.4.5 into the argocd namespace.
#
# Four things here are deliberate:
#
#   * The manifest URL carries a version tag, not `stable`. `stable` is a moving
#     branch, so applying it twice installs two different versions and nothing in
#     the cluster records which one you got.
#
#   * --server-side is required, not optional. Client side apply stores the whole
#     resource in a kubectl.kubernetes.io/last-applied-configuration annotation,
#     which is capped at 262144 bytes. The ApplicationSet CRD is about 374 KB, so
#     a plain `kubectl apply` fails on that one object and leaves you with an
#     install that looks fine until ApplicationSets silently do nothing.
#
#   * The script waits for the cluster to settle before applying anything. Nodes
#     report Ready well before k3s has finished deploying its own add-ons, and an
#     apply aimed at an API server that is still doing that work fails with a wall
#     of `TLS handshake timeout`.
#
#   * The readiness waits retry instead of taking one shot. A single long watch
#     dies with `client connection lost` when the API server is briefly busy, and
#     `kubectl wait` reports `timed out waiting for the condition` over an install
#     that is in fact perfectly healthy.
set -euo pipefail

ARGOCD_VERSION="${ARGOCD_VERSION:-v3.4.5}"
MANIFEST="https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

# Retry a command until it succeeds or the budget runs out. Used for anything
# that talks to the API server, because "the connection dropped" and "the thing
# you asked about is not ready" look identical from the exit code.
retry_until() {
  local budget="$1"; shift
  local deadline=$(( SECONDS + budget ))
  until "$@" >/dev/null 2>&1; do
    if (( SECONDS >= deadline )); then
      return 1
    fi
    sleep 5
  done
}

echo "waiting for the API server to answer..."
retry_until 300 kubectl get --raw /healthz \
  || { echo "the API server never became reachable. Is the cluster running? Try: kubectl cluster-info"; exit 1; }

# k3s installs CoreDNS, Traefik, local-path and metrics-server after the nodes
# report Ready. Applying 300 KB of manifests while that is still running is what
# produces the TLS handshake timeouts.
#
# The field selector excludes pods that have already finished. k3s runs its
# add-on installs as Jobs, and a Completed pod never reports Ready, so waiting on
# every pod in the namespace would wait forever on something that already worked.
echo "waiting for the cluster's own add-ons to finish starting..."
retry_until 300 kubectl wait --for=condition=Ready pod -n kube-system \
  --all --field-selector=status.phase!=Succeeded --timeout=30s \
  || echo "note: some kube-system pods are still not Ready. Continuing anyway."

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts -f "$MANIFEST"

echo "waiting for Argo CD to become available..."
retry_until 600 kubectl wait --for=condition=Available --timeout=60s deployment --all -n argocd \
  || echo "note: not every Deployment reported Available. Check the pod list below."
retry_until 300 kubectl rollout status statefulset/argocd-application-controller -n argocd --timeout=60s \
  || echo "note: the application controller did not report rolled out. Check the pod list below."

# `kubectl wait` alone is not proof of health: a Deployment reports Available as
# soon as one replica is up, so a node evicting pods still passes. Check both.
echo
echo "pods:"
kubectl get pods -n argocd
echo
echo "node disk pressure (want False everywhere):"
kubectl get nodes -o custom-columns='NAME:.metadata.name,DISK:.status.conditions[?(@.type=="DiskPressure")].status' --no-headers
echo
echo "running version:"
kubectl get deploy argocd-server -n argocd -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
