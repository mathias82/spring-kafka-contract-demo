package io.github.mathias82.demo.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record OrderEvent(
        @NotBlank String orderId,
        @NotNull Double amount,
        String createdAt
) {}