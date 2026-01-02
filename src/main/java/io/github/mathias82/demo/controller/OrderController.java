package io.github.mathias82.demo.controller;

import io.github.mathias82.demo.consumer.OrderConsumer;
import io.github.mathias82.demo.model.OrderEvent;
import io.github.mathias82.demo.producer.OrderProducer;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderProducer producer;
    private final OrderConsumer consumer;

    public OrderController(OrderProducer producer, OrderConsumer consumer) {
        this.producer = producer;
        this.consumer = consumer;
    }

    /**
     * Produce VALID event (v1 compatible)
     */
    @PostMapping
    public ResponseEntity<String> createOrder(@RequestBody OrderEvent request) {

        OrderEvent event = new OrderEvent(
                request.orderId(),
                request.amount(),
                request.createdAt() != null
                        ? request.createdAt()
                        : Instant.now().toString()
        );

        producer.send(event);

        return ResponseEntity.ok("Order event sent");
    }

    /**
     * Consume already received events (demo only)
     */
    @GetMapping("/events")
    public List<OrderEvent> consume() {
        return consumer.getEvents();
    }

    /**
     * Clear in-memory events
     */
    @DeleteMapping("/events")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void clear() {
        consumer.clear();
    }
}
