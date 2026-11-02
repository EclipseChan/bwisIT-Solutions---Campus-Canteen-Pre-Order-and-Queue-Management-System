package com.bwisit.canteen.controller;

import com.bwisit.canteen.dto.NotificationResponse;
import com.bwisit.canteen.security.AuthUser;
import com.bwisit.canteen.service.NotificationService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {
    private final NotificationService notifications;

    public NotificationController(NotificationService notifications) {
        this.notifications = notifications;
    }

    @GetMapping
    public List<NotificationResponse> mine(@AuthenticationPrincipal AuthUser user,
                                           @RequestParam(defaultValue = "false") boolean unreadOnly) {
        return notifications.list(user.id(), unreadOnly);
    }

    @GetMapping("/unread-count")
    public Map<String, Long> unreadCount(@AuthenticationPrincipal AuthUser user) {
        return Map.of("unread", notifications.unreadCount(user.id()));
    }

    @PatchMapping("/{id}/read")
    public NotificationResponse markRead(@AuthenticationPrincipal AuthUser user, @PathVariable Integer id) {
        return notifications.markRead(user.id(), id);
    }
}
