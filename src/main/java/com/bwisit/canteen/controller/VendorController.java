package com.bwisit.canteen.controller;

import com.bwisit.canteen.dto.MenuItemResponse;
import com.bwisit.canteen.dto.VendorResponse;
import com.bwisit.canteen.repository.MenuItemRepository;
import com.bwisit.canteen.repository.VendorRepository;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/vendors")
public class VendorController {
    private final VendorRepository vendors;
    private final MenuItemRepository menuItems;

    public VendorController(VendorRepository vendors, MenuItemRepository menuItems) {
        this.vendors = vendors;
        this.menuItems = menuItems;
    }

    @GetMapping
    public List<VendorResponse> activeVendors() {
        return vendors.findByActiveTrue().stream().map(VendorResponse::from).toList();
    }

    @GetMapping("/{vendorId}/menu")
    public List<MenuItemResponse> menu(@PathVariable Integer vendorId) {
        return menuItems.findByVendorIdAndAvailableTrue(vendorId).stream()
                .map(MenuItemResponse::from).toList();
    }
}
