package com.bwisit.canteen.controller;

import com.bwisit.canteen.dto.AvailabilityRequest;
import com.bwisit.canteen.dto.DeleteResult;
import com.bwisit.canteen.dto.MenuItemRequest;
import com.bwisit.canteen.dto.MenuItemResponse;
import com.bwisit.canteen.security.AuthUser;
import com.bwisit.canteen.service.MenuService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/vendor/menu")
public class VendorMenuController {
    private final MenuService menu;

    public VendorMenuController(MenuService menu) {
        this.menu = menu;
    }

    @GetMapping
    public List<MenuItemResponse> myMenu(@AuthenticationPrincipal AuthUser user) {
        return menu.list(user.id());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public MenuItemResponse add(@AuthenticationPrincipal AuthUser user,
                                @Valid @RequestBody MenuItemRequest req) {
        return menu.create(user.id(), req);
    }

    @PutMapping("/{itemId}")
    public MenuItemResponse edit(@AuthenticationPrincipal AuthUser user, @PathVariable Integer itemId,
                                 @Valid @RequestBody MenuItemRequest req) {
        return menu.update(user.id(), itemId, req);
    }

    @PatchMapping("/{itemId}/availability")
    public MenuItemResponse setAvailability(@AuthenticationPrincipal AuthUser user,
                                            @PathVariable Integer itemId,
                                            @Valid @RequestBody AvailabilityRequest req) {
        return menu.setAvailability(user.id(), itemId, req.available());
    }

    @DeleteMapping("/{itemId}")
    public DeleteResult remove(@AuthenticationPrincipal AuthUser user, @PathVariable Integer itemId) {
        return menu.delete(user.id(), itemId);
    }
}