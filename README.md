# RabbitMQ Dynamic Consumer with KEDA

This project demonstrates a dynamic scaling system for RabbitMQ consumers using Kubernetes and KEDA.

## 🚀 Quick Start

### 1. Deploy
Build Docker images and apply Kubernetes manifests (RabbitMQ, Consumers, KEDA ScaledObject).
```bash
./deployment.sh
```

### 2. Watch Status
Monitor the **RabbitMQ Queue size**, **Consumer Pods**, and **HPA scaling** in real-time.
```bash
./watch_status.sh
```

### 3. Simulate Load
Run a local producer to flush messages to the queue.
```bash
./simulated_producer.sh
```
*Modify `MESSAGE_RATE` or stop the script to control the load.*

### 🧹 Cleanup
Remove all resources including KEDA.
```bash
./delete_deployment.sh
```

## Scaling Logic
- **Target**: 100 messages per consumer.
- **Max Replicas**: 10.
- **Behavior**: If queue > 100, KEDA adds consumer pods.
