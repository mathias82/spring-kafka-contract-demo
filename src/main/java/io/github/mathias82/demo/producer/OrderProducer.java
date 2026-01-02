package io.github.mathias82.demo.producer;

import io.github.mathias82.demo.model.OrderEvent;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
public class OrderProducer {

    private final KafkaTemplate<String, OrderEvent> kafkaTemplate;

    public OrderProducer(KafkaTemplate<String, OrderEvent> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void sendOrder() {
        OrderEvent event = new OrderEvent(
                "order-1",
                99.99,
                Instant.now().toString()
        );

        kafkaTemplate.send("order-events", event.orderId(), event);
    }
}