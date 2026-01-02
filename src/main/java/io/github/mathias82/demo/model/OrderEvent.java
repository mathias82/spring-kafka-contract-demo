package io.github.mathias82.demo.model;

public record OrderEvent(
        String orderId,
        double amount,
        String createdAt
) {}