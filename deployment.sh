#!/bin/bash
set -e

echo "Building Docker images..."
# Check if we are inside minikube
if [ -n "$MINIKUBE_ACTIVE_DOCKERD" ]; then
    echo "Minikube environment detected."
else
    echo "Building generic docker images. If using Minikube/Kind, ensure images are loaded."
fi

docker build -t my-producer:latest -f Dockerfile.producer .
docker build -t my-consumer:latest -f Dockerfile.consumer .

# Attempt to load into Kind if kind command exists and cluster is running
if command -v kind &> /dev/null; then
    if kind get clusters | grep -q "kind"; then # Default cluster name 'kind'
        echo "Loading images into Kind cluster 'kind'..."
        kind load docker-image my-producer:latest
        kind load docker-image my-consumer:latest
    fi
fi

# Apply KEDA CRDs
kubectl apply -f https://github.com/kedacore/keda/releases/download/v2.10.0/keda-2.10.0.yaml

# Applying manifests...
kubectl apply -f k8s/rabbitmq.yaml

echo "Waiting for RabbitMQ to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/rabbitmq

# kubectl apply -f k8s/producer.yaml # Disabled to allow manual simulation
kubectl apply -f k8s/consumer.yaml
kubectl apply -f k8s/keda-scaledobject.yaml

echo "Deployment complete."
