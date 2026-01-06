This repository is part of the **Kafka Contract Enforcement** initiative:
- 🔧 Starter: https://github.com/mathias82/spring-kafka-contract-starter
- 🌐 Live Demo: https://mathias82.github.io/spring-kafka-contract-demo/

# 🧪 Spring Kafka Contract -- Demo Project

A **fully runnable demo** showcasing **fail-fast Kafka Schema Registry
contract validation** using **Spring Boot**, **Apache Kafka**, **Avro**,
and **Confluent Schema Registry**.

This project demonstrates how the\
👉 **spring-kafka-contract-starter**\
can prevent broken Kafka deployments by validating schema contracts **at
application startup**.

------------------------------------------------------------------------

## 🎯 What This Demo Shows

This demo answers a very practical question:

> *What actually happens when schemas are missing, incompatible, or
> evolve incorrectly in a real Spring Boot Kafka application?*

It demonstrates:

-   Kafka producer & consumer with Avro\
-   Schema Registry subject creation\
-   Schema evolution (compatible & incompatible)\
-   **Fail-fast application startup** when contracts are broken\
-   How startup validation prevents late production failures

This is **not a library**, but a **reference project** you can run,
inspect, and experiment with.

------------------------------------------------------------------------

## 🧩 Architecture

Spring Boot Producer\
↓\
Apache Kafka\
↓\
Spring Boot Consumer\
↓\
PostgreSQL

Schema Registry (Avro)\
↑\
Contract validation at startup

------------------------------------------------------------------------

## 🚀 Tech Stack

-   Java 17\
-   Spring Boot 3.x\
-   Apache Kafka\
-   Confluent Schema Registry\
-   Avro\
-   PostgreSQL\
-   Docker & Docker Compose

------------------------------------------------------------------------

## 🔗 Related Project

This demo is built to showcase:

👉 **Spring Kafka Contract Starter**\
https://github.com/mathias82/spring-kafka-contract-starter

The starter enforces Kafka schema contracts **before** the application
starts.

------------------------------------------------------------------------

## 📦 How to Run the Demo

### 1️⃣ Start infrastructure

docker compose up -d

This starts Kafka, Schema Registry and PostgreSQL.

### 2️⃣ Run the applications

./mvnw spring-boot:run

### 3️⃣ Observe Startup Validation

-   Application starts if schemas are valid\
-   Application fails if a subject is missing or incompatible

Broken contracts = **no startup**.

------------------------------------------------------------------------

## 📄 Configuration Example

kafka:
  contract:
    enabled: true
    compatibility: BACKWARD
    registry:
      type: confluent
      url: http://localhost:8081
    subjects:
      - name: order-events-value
        schema-file: classpath:schemas/order-event.avsc

------------------------------------------------------------------------

## 📚 Learn More

Medium article:\
https://medium.com/@mstauroy/building-a-kafka-event-driven-spring-boot-application-with-avro-schema-registry-and-postgresql-45114526fb87](https://medium.com/@mstauroy/fail-fast-kafka-schema-contracts-in-spring-boot-before-production-breaks-1b080204b49e

Reddit discussion:\
https://www.reddit.com/r/apachekafka/comments/1q42urd/kafka_schema_registry_avro_with_spring_boot/](https://www.reddit.com/r/apachekafka/comments/1q43hs6/failfast_kafka_schema_registry_compatibility/

------------------------------------------------------------------------

## 👀 Who This Demo Is For

-   Kafka + Schema Registry users\
-   Spring Boot engineers using Avro\
-   Teams dealing with schema evolution\
-   Anyone bitten by late Kafka failures

------------------------------------------------------------------------

## ⭐ Final Note

This demo exists to make schema contracts **visible and testable**.

If you find it useful, check out the starter:
https://github.com/mathias82/spring-kafka-contract-starter
