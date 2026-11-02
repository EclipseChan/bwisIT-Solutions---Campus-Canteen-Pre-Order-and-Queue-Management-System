package com.bwisit.canteen.controller;

import com.bwisit.canteen.dto.OrderResponse;
import com.bwisit.canteen.dto.PlaceOrderRequest;
import com.bwisit.canteen.security.AuthUser;
import com.bwisit.canteen.service.OrderService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/** Student-facing order endpoints. */
@RestController
@RequestMapping("/api/orders")
public class OrderController {
    private final OrderService orders;

    public OrderController(OrderService orders) {
        this.orders = orders;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public OrderResponse place(@AuthenticationPrincipal AuthUser user, @Valid @RequestBody PlaceOrderRequest req) {
        return orders.place(user.id(), req);
    }

    @GetMapping
    public List<OrderResponse> myOrders(@AuthenticationPrincipal AuthUser user) {
        return orders.listForStudent(user.id());
    }

    @GetMapping("/{orderId}")
    public OrderResponse myOrder(@AuthenticationPrincipal AuthUser user, @PathVariable Integer orderId) {
        return orders.getForStudent(user.id(), orderId);
    }

    @PostMapping("/{orderId}/cancel")
    public OrderResponse cancel(@AuthenticationPrincipal AuthUser user, @PathVariable Integer orderId) {
        return orders.cancelAsStudent(user.id(), orderId);
    }
}
