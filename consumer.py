import pika
import time
import os
import sys
import json

# Configuration
RABBITMQ_HOST = os.getenv('RABBITMQ_HOST', 'localhost')
QUEUE_NAME = os.getenv('QUEUE_NAME', 'task_queue')
# Simulate processing time in seconds
PROCESSING_TIME = float(os.getenv('PROCESSING_TIME', '0.5'))

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
    print(f" [*] Waiting for messages in {QUEUE_NAME}. Processing time: {PROCESSING_TIME}s")

    def callback(ch, method, properties, body):
        try:
            data = json.loads(body)
            print(f" [x] Received {data.get('id', 'unknown')}")
        except json.JSONDecodeError:
            print(f" [x] Received raw: {body}")

        # Simulate work
        time.sleep(PROCESSING_TIME)
        print(" [x] Done")
        ch.basic_ack(delivery_tag=method.delivery_tag)

    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(queue=QUEUE_NAME, on_message_callback=callback)

    try:
        channel.start_consuming()
    except KeyboardInterrupt:
        channel.stop_consuming()
    finally:
        connection.close()

if __name__ == '__main__':
    # Wait a bit for RabbitMQ to start
    time.sleep(5)
    main()
