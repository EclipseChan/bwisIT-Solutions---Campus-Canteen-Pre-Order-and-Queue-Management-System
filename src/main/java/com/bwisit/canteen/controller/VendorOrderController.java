package com.bwisit.canteen.controller;

import com.bwisit.canteen.dto.OrderResponse;
import com.bwisit.canteen.dto.StatusRequest;
import com.bwisit.canteen.security.AuthUser;
import com.bwisit.canteen.service.OrderService;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/** Vendor-facing order endpoints: see incoming orders and move them through the workflow. */
@RestController
@RequestMapping("/api/vendor/orders")
public class VendorOrderController {
    private final OrderService orders;

    public VendorOrderController(OrderService orders) {
        this.orders = orders;
    }

    @GetMapping
    public List<OrderResponse> incoming(@AuthenticationPrincipal AuthUser user,
                                        @RequestParam(required = false) String status) {
        return orders.listForVendor(user.id(), status);
    }

    @PatchMapping("/{orderId}/status")
    public OrderResponse updateStatus(@AuthenticationPrincipal AuthUser user, @PathVariable Integer orderId,
                                      @Valid @RequestBody StatusRequest req) {
        return orders.updateStatusAsVendor(user.id(), orderId, req.status());
    }
}
