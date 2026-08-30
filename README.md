This repository is part of the **Kafka Contract Enforcement** initiative:
- 🔧 Starter: https://github.com/mathias82/spring-kafka-contract-starter
- 🌐 Live Demo: https://mathias82.github.io/spring-kafka-contract-demo/

# 🧪 Spring Kafka Contract Demo

A runnable Spring Boot demo for **fail-fast Kafka Schema Registry contract validation** with Apache Kafka, Avro, and Confluent Schema Registry.

The demo uses `spring-kafka-contract-starter` 0.2.0 and proves both startup contract enforcement and a real producer → Kafka → consumer round trip.

## Architecture

```text
REST API
   │
   ▼
Spring Boot producer ──► Kafka ──► Spring Boot consumer
        │                              │
        └──────── Schema Registry ─────┘
                     ▲
                     │
            startup contract check
```

The consumer keeps received events in memory for demo purposes. PostgreSQL is not required.

## Tech stack

- Java 21
- Spring Boot 3.3
- Spring Kafka
- Apache Kafka
- Confluent Schema Registry
- Avro
- Docker Compose

## Run the demo

### 1. Start Kafka and Schema Registry

```bash
docker compose up -d
```

The `schema-init` service waits for Schema Registry, configures `BACKWARD` compatibility, and registers the `order-events-value` v1 subject used by the application.

### 2. Start the Spring Boot application

```bash
mvn spring-boot:run
```

### 3. Verify the real Kafka flow

```bash
curl -X POST http://localhost:8080/api/orders \
  -H 'Content-Type: application/json' \
  -d '{"orderId":"demo-1","amount":42.5,"createdAt":"2026-08-30T00:00:00Z"}'

curl http://localhost:8080/api/orders/events
```

The second call should eventually contain `demo-1`, proving the event was serialized, published to Kafka, consumed, deserialized, and exposed by the demo.

## Contract configuration

```yaml
kafka:
  contract:
    enabled: true
    compatibility: BACKWARD
    registry:
      url: http://localhost:8081
      connect-timeout-ms: 2000
      read-timeout-ms: 5000
    subjects:
      - name: order-events-value
        schema-file: classpath:schemas/order-event-v1.avsc
        schema-type: AVRO
```

## Schema evolution scenarios

- `order-event-v1.avsc` — baseline runtime contract
- `order-event-v2.avsc` — backward-compatible evolution that adds optional `customerNote` with a default
- `order-event-v3.avsc` — intentionally breaking evolution

Only v1 is compiled into the runtime generated Avro class. v2 and v3 are contract-evolution examples, which avoids ambiguous duplicate generated classes with the same Avro full name.

To test startup enforcement, point `schema-file` to v2 or v3 and restart the application. Under `BACKWARD`, v2 should remain compatible while v3 should fail startup.

## CI coverage

The GitHub Actions workflow:

1. installs the starter version under test
2. starts Kafka and Schema Registry
3. waits for schema initialization
4. builds the demo
5. starts Spring Boot
6. POSTs a unique order
7. polls the consumer endpoint until that exact order is observed

This means CI verifies the full demo path rather than only checking that the HTTP server starts.

## Purpose

This repository is a reference application, not a library. Its goal is to make Kafka schema contract failures visible, reproducible, and testable before deployment.
