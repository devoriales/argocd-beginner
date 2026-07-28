#!/usr/bin/env bash
# Install Argo CD 3.4.5 into the argocd namespace.
#
# Two things here are deliberate:
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
set -euo pipefail

ARGOCD_VERSION="${ARGOCD_VERSION:-v3.4.5}"
MANIFEST="https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts -f "$MANIFEST"

kubectl wait --for=condition=Available --timeout=300s deployment --all -n argocd
kubectl rollout status statefulset/argocd-application-controller -n argocd --timeout=300s

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
