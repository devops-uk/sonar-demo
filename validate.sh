#!/usr/bin/env bash
set -euo pipefail

NS="apps"
APP="sonar-demo"
EXPECTED_IMAGE="${1:-}"

echo "1) Waiting for rollout..."
kubectl -n "$NS" rollout status deploy/"$APP" --timeout=180s

echo "2) Pod status:"
kubectl -n "$NS" get pods -l app="$APP" -o wide

POD="$(kubectl -n "$NS" get pods -l app="$APP" -o jsonpath='{.items[0].metadata.name}')"
IMG="$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{.spec.containers[0].image}')"
RESTARTS="$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{.status.containerStatuses[0].restartCount}')"
READY="$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{.status.containerStatuses[0].ready}')"

echo "3) Running checks:"
echo "   Pod: $POD"
echo "   Image: $IMG"
echo "   Ready: $READY"
echo "   Restarts: $RESTARTS"

if [[ -n "$EXPECTED_IMAGE" && "$IMG" != "$EXPECTED_IMAGE" ]]; then
  echo "❌ Image mismatch: expected $EXPECTED_IMAGE but got $IMG"
  exit 1
fi

if [[ "$READY" != "true" ]]; then
  echo "❌ Pod is not Ready"
  kubectl -n "$NS" describe pod "$POD" | tail -80
  exit 1
fi

echo "4) Last logs:"
kubectl -n "$NS" logs "$POD" --tail=50 || true

echo "✅ Validation passed."
