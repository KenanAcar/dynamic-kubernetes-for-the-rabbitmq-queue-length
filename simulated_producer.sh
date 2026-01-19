#!/bin/bash
set -e

echo "Starting port-forward to RabbitMQ..."
# Run port-forward in background
kubectl port-forward svc/rabbitmq 5672:5672 > /dev/null 2>&1 &
PF_PID=$!

# Function to cleanup background process
cleanup() {
    echo "Stopping port-forward..."
    kill $PF_PID
}
trap cleanup EXIT

echo "Waiting for port-forward..."
sleep 3

echo "Starting local producer. Press Ctrl+C to stop."
export RABBITMQ_HOST=localhost
export QUEUE_NAME=task_queue
export MESSAGE_RATE=10.0

python3 producer.py
