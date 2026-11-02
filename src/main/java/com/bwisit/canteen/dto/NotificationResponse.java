package com.bwisit.canteen.dto;

import com.bwisit.canteen.entity.Notification;
import java.time.LocalDateTime;

public record NotificationResponse(Integer id, Integer orderId, String message,
                                   LocalDateTime sentAt, boolean read) {
    public static NotificationResponse from(Notification n) {
        return new NotificationResponse(n.getId(), n.getOrder().getId(), n.getMessage(),
                n.getSentAt(), n.isRead());
    }
}
