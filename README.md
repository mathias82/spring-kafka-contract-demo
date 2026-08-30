This repository is part of the **Kafka Contract Enforcement** initiative:
- 🔧 Starter: https://github.com/mathias82/spring-kafka-contract-starter
- 🌐 Live Demo: https://mathias82.github.io/spring-kafka-contract-demo/

# 🧪 Spring Kafka Contract Demo

A runnable Spring Boot demo for **fail-fast Kafka Schema Registry contract validation** with Apache Kafka, Avro, and Confluent Schema Registry.

The demo shows how `spring-kafka-contract-starter` prevents an application from starting when a required schema subject is missing, the effective compatibility mode is unexpected, or a local schema is incompatible with the latest registered version.

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

With the initialized v1 contract the application should start successfully.

### 3. Verify the application

```bash
curl http://localhost:8080/api/orders/events
```

A clean startup returns an empty JSON array until events are produced.

## Contract configuration

```yaml
kafka:
  contract:
    enabled: true
    compatibility: BACKWARD
    registry:
      type: confluent
      url: http://localhost:8081
      connect-timeout-ms: 2000
      read-timeout-ms: 5000
    subjects:
      - name: order-events-value
        schema-file: classpath:schemas/order-event-v1.avsc
        schema-type: AVRO
```

## Schema evolution scenarios

The project includes Avro schemas for compatible and breaking evolution scenarios. You can replace the configured local schema with another version and restart the application to observe the fail-fast behavior.

- `order-event-v1.avsc` — baseline contract
- `order-event-v2.avsc` — evolution example
- `order-event-v3.avsc` — breaking evolution example

The Postman collection under `postman/` and the GitHub Pages walkthrough provide additional demo steps.

## Related project

Starter repository:

https://github.com/mathias82/spring-kafka-contract-starter

## Background

Medium article:

https://medium.com/@mstauroy/fail-fast-kafka-schema-contracts-in-spring-boot-before-production-breaks-1b080204b49e

Reddit discussion:

https://www.reddit.com/r/apachekafka/comments/1q43hs6/failfast_kafka_schema_registry_compatibility/

## Purpose

This repository is a reference application, not a library. Its goal is to make Kafka schema contract failures visible, reproducible, and testable before deployment.
