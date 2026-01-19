import pika
import time
import os
import json
import random
import sys

# Configuration
RABBITMQ_HOST = os.getenv('RABBITMQ_HOST', 'localhost')
QUEUE_NAME = os.getenv('QUEUE_NAME', 'task_queue')
# Rate: messages per second. Default 1.
MESSAGE_RATE = float(os.getenv('MESSAGE_RATE', '1.0')) 

def main():
    print(f"Connecting to RabbitMQ at {RABBITMQ_HOST}...")
    try:
        connection = pika.BlockingConnection(
            pika.ConnectionParameters(host=RABBITMQ_HOST, heartbeat=0)
        )
        channel = connection.channel()
    except Exception as e:
        print(f"Failed to connect to RabbitMQ: {e}")
        sys.exit(1)

    channel.queue_declare(queue=QUEUE_NAME, durable=True)

    print(f"Producer started. Target Queue: {QUEUE_NAME}. Rate: {MESSAGE_RATE} msg/s")

    try:
        while True:
            message = {
                'id': random.randint(1000, 9999),
                'alert': 'High load detected',
                'timestamp': time.time(),
                'payload': "x" * random.randint(10, 100) # Random payload
            }
            body = json.dumps(message)
            
            channel.basic_publish(
                exchange='',
                routing_key=QUEUE_NAME,
                body=body,
                properties=pika.BasicProperties(
                    delivery_mode=pika.DeliveryMode.Persistent
                )
            )
            print(f" [x] Sent {message['id']}")
            
            # Sleep to match rate
            if MESSAGE_RATE > 0:
                time.sleep(1.0 / MESSAGE_RATE)

    except KeyboardInterrupt:
        print("Interrupted")
    finally:
        connection.close()

if __name__ == '__main__':
    # Wait a bit for RabbitMQ to start if running in containers together
    time.sleep(5) 
    main()
