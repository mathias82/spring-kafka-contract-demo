package io.github.mathias82.demo.producer;

import io.github.mathias82.demo.model.OrderEvent;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
public class OrderProducer {

    private static final String TOPIC = "order-events";

    private final KafkaTemplate<String, OrderEvent> kafkaTemplate;

    public OrderProducer(KafkaTemplate<String, OrderEvent> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void send(OrderEvent event) {
        kafkaTemplate.send(TOPIC, event.orderId(), event);
    }
}