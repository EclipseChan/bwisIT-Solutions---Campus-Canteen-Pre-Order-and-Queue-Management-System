package com.bwisit.canteen.dto;

import java.math.BigDecimal;

public record OrderLineResponse(Integer itemId, String itemName, Integer quantity,
                                BigDecimal priceAtOrder, BigDecimal subtotal) {
}
