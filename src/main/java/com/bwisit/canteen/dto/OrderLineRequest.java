package com.bwisit.canteen.dto;

import jakarta.validation.constraints.*;

public record OrderLineRequest(
        @NotNull Integer itemId,
        @NotNull @Min(1) @Max(20) Integer quantity) {
}
