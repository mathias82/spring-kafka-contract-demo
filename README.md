# Spring Kafka Contract Demo

This project demonstrates how to enforce **Kafka data contracts** at application startup
using **Schema Registry** and the  
`spring-kafka-contract-starter`.

The goal is to **fail fast** if:
- a required schema is missing
- a schema is incompatible
- a breaking change is introduced

---

## 🚨 The Problem

In many Kafka-based systems:

- Producers start without validating schemas
- Consumers fail at runtime (often in production)
- Breaking changes propagate silently
- Teams discover issues **after data is already corrupted**

Kafka itself does **not** enforce data contracts.

---

## ✅ The Solution

This demo shows how to:

- Declare expected schemas via configuration
- Validate schema existence at startup
- Enforce compatibility rules (BACKWARD / FORWARD / FULL)
- Prevent applications from starting with invalid contracts

All without writing custom validation code.

---

## 🧱 Architecture

Spring Boot App
|
|-- StartupSchemaValidator
|-- Schema Registry (Confluent / Apicurio)
|
Kafka Broker


---

## ⚙️ Configuration

```yaml
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

▶️ Running the Demo
1️⃣ Start infrastructure

docker-compose up

2️⃣ Start the application

mvn spring-boot:run

If the schema exists and is compatible → ✅ application starts.

If not → ❌ application fails immediately.

🧪 What to Try

- Remove a required field from the schema
- Change a field type
- Rename the subject
- Switch compatibility mode

Observe how the application fails before producing or consuming any data.

🎯 Key Takeaways

- Kafka does not enforce contracts by default
- Schema Registry alone is not enough
- Validation must happen before runtime
- This starter enables safe Kafka evolution