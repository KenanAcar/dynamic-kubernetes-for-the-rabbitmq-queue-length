#!/bin/bash
set -e

echo "Deleting deployments and services..."
kubectl delete -f k8s/ || true

echo "Deleting KEDA CRDs and resources..."
kubectl delete -f https://github.com/kedacore/keda/releases/download/v2.10.0/keda-2.10.0.yaml --ignore-not-found

echo "Scaling down local producer (if running via port-forward)..."
# We can't easily kill the specific background port-forward from here unless we tracked PID.
# But we can remind the user.
echo "Note: If you have a 'simulated_producer.sh' running, please stop it manually (Ctrl+C)."

echo "Cleanup complete."
