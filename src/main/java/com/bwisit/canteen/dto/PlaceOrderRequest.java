package com.bwisit.canteen.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.time.LocalTime;
import java.util.List;

public record PlaceOrderRequest(
        @NotNull Integer vendorId,
        @NotNull LocalTime pickupTime,
        @NotEmpty @Size(max = 30) @Valid List<OrderLineRequest> items) {
}
