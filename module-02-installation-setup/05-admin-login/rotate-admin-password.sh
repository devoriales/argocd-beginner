#!/usr/bin/env bash
# Rotate the Argo CD admin password and clean up the bootstrap secret.
#
# WHY THIS DOES NOT USE `argocd account update-password`
#
# That command needs a logged-in CLI session, and the CLI talks gRPC. If you
# followed the Ingress lesson you set server.insecure=true, so argocd-server now
# speaks plain HTTP, and gRPC over a plain-HTTP port-forward does not negotiate:
#
#   --insecure              interactive "server is not configured with TLS.
#                           Proceed (y/n)?" prompt, which in a script dies on EOF
#   --plaintext             rpc error: code = Unimplemented, 404, text/plain
#   --plaintext --grpc-web  POST /session.SessionService/Create -> 404
#
# The REST API on the same port is unaffected, and the password itself is just a
# bcrypt hash in a Secret. So this rotates it declaratively, which works the same
# whether or not TLS is on, needs no session, and is the approach that actually
# fits a course about declarative configuration.
#
# ORDER STILL MATTERS. argocd-initial-admin-secret is NOT removed by the change:
# it survives holding the retired password in plaintext. Delete it only after the
# new password is confirmed working.
set -euo pipefail

: "${NEW_PASSWORD:?set NEW_PASSWORD to the password you want}"
SERVER_URL="${SERVER_URL:-http://localhost:8080}"   # a running port-forward

# `argocd account bcrypt` hashes locally. No server, no session.
HASH="$(argocd account bcrypt --password "$NEW_PASSWORD")"

kubectl -n argocd patch secret argocd-secret -p "$(cat <<JSON
{"stringData": {
  "admin.password": "${HASH}",
  "admin.passwordMtime": "$(date +%FT%T%Z)"
}}
JSON
)"

# argocd-server picks the change up within a few seconds; give it a moment.
sleep 5

# Confirm over REST, which works regardless of the transport question above.
code="$(curl -s -o /tmp/argocd-session.json -w '%{http_code}' \
  -X POST "${SERVER_URL}/api/v1/session" \
  -H 'Content-Type: application/json' \
  -d "{\"username\":\"admin\",\"password\":\"${NEW_PASSWORD}\"}")"

if [ "$code" != "200" ]; then
  echo "new password did NOT authenticate (HTTP ${code}). Leaving the bootstrap secret in place." >&2
  exit 1
fi
echo "new password confirmed (HTTP 200, session token issued)"

kubectl delete secret argocd-initial-admin-secret -n argocd --ignore-not-found
echo "bootstrap secret removed"
