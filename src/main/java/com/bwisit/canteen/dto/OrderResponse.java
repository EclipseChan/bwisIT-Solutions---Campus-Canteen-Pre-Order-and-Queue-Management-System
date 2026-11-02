package com.bwisit.canteen.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

public record OrderResponse(Integer orderId, Integer vendorId, String vendorName, String studentName,
                            LocalDateTime orderDate, LocalTime pickupTime, String status,
                            Integer queueNumber, LocalDate queueDate, long peopleAhead,
                            List<OrderLineResponse> items, BigDecimal total) {
}
