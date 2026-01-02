package io.github.mathias82.demo.consumer;

import io.github.mathias82.demo.model.OrderEvent;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@Component
public class OrderConsumer {

    private final List<OrderEvent> receivedEvents = new CopyOnWriteArrayList<>();

    @KafkaListener(topics = "order-events", groupId = "demo-consumer")
    public void onMessage(OrderEvent event) {
        receivedEvents.add(event);
    }

    public List<OrderEvent> getEvents() {
        return receivedEvents;
    }

    public void clear() {
        receivedEvents.clear();
    }
}
