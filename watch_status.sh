#!/bin/bash

# Function to run the monitoring command
run_monitor() {
    clear
    echo "=== RabbitMQ Dynamic Consumer Sytem Status ==="
    echo "Press Ctrl+C to exit."
    echo ""
    echo "--- PODS ---"
    kubectl get pods
    echo ""
    echo "--- HPA (Scaling) ---"
    kubectl get hpa
    echo ""
    echo "--- RABBITMQ QUEUES ---"
    MQ_POD=$(kubectl get pod -l app=rabbitmq -o jsonpath="{.items[0].metadata.name}")
    if [ -n "$MQ_POD" ]; then
        kubectl exec "$MQ_POD" -- rabbitmqctl list_queues name messages --no-table-headers 2>/dev/null || echo "Unable to fetch queue stats"
    else
        echo "RabbitMQ pod not found"
    fi
    echo ""
    echo "--- CONSUMER DEPLOYMENT ---"
    kubectl get deployment consumer
    echo ""
    echo "Last updated: $(date)"
}

# Check if 'watch' command exists
if command -v watch &> /dev/null; then
    # Use watch if available for smoother updating
    watch -n 1 "kubectl get pods; echo ''; kubectl get hpa; echo ''; kubectl get deployment consumer"
else
    # Fallback loop
    while true; do
        run_monitor
        sleep 2
    done
fi
