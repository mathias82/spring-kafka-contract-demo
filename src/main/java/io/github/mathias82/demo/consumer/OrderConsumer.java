package io.github.mathias82.demo.consumer;

import io.github.mathias82.demo.model.OrderEvent;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class OrderConsumer {

    @KafkaListener(topics = "order-events")
    public void onMessage(OrderEvent event) {
        System.out.println("Received order: " + event);
    }
}
