#!/usr/bin/env bash
# Rotate the Argo CD admin password and clean up the bootstrap secret.
#
# Order matters. argocd-initial-admin-secret is NOT removed by the password
# change: it survives holding the retired password in plaintext. Delete it only
# after the new password is confirmed working, because deleting it first and
# then failing to log in locks you out of the only admin account.
set -euo pipefail

: "${NEW_PASSWORD:?set NEW_PASSWORD to the password you want}"
SERVER="${SERVER:-localhost:8080}"

OLD="$(kubectl get secret argocd-initial-admin-secret -n argocd \
        -o jsonpath='{.data.password}' | base64 -d)"

argocd login "$SERVER" --username admin --password "$OLD" --insecure
argocd account update-password --current-password "$OLD" --new-password "$NEW_PASSWORD"

# Prove the new credential works before destroying the old one's copy.
argocd login "$SERVER" --username admin --password "$NEW_PASSWORD" --insecure
echo "new password confirmed"

kubectl delete secret argocd-initial-admin-secret -n argocd
echo "bootstrap secret removed"
