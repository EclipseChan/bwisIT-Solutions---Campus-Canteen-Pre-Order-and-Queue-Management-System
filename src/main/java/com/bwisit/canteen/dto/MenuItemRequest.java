package com.bwisit.canteen.dto;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;

public record MenuItemRequest(
        @NotBlank @Size(max = 100) String itemName,
        @NotNull @DecimalMin("0.00") @Digits(integer = 6, fraction = 2) BigDecimal price,
        Boolean available) {
}