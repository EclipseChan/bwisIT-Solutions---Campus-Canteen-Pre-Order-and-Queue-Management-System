package com.bwisit.canteen.service;

import com.bwisit.canteen.dto.DeleteResult;
import com.bwisit.canteen.dto.MenuItemRequest;
import com.bwisit.canteen.dto.MenuItemResponse;
import com.bwisit.canteen.entity.MenuItem;
import com.bwisit.canteen.entity.Vendor;
import com.bwisit.canteen.exception.ApiException;
import com.bwisit.canteen.repository.MenuItemRepository;
import com.bwisit.canteen.repository.OrderItemRepository;
import com.bwisit.canteen.repository.VendorRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
public class MenuService {
    private final MenuItemRepository items;
    private final VendorRepository vendors;
    private final OrderItemRepository orderItems;

    public MenuService(MenuItemRepository items, VendorRepository vendors, OrderItemRepository orderItems) {
        this.items = items;
        this.vendors = vendors;
        this.orderItems = orderItems;
    }

    @Transactional(readOnly = true)
    public List<MenuItemResponse> list(Integer vendorId) {
        return items.findByVendorIdOrderByItemNameAsc(vendorId).stream()
                .map(MenuItemResponse::from).toList();
    }

    @Transactional
    public MenuItemResponse create(Integer vendorId, MenuItemRequest req) {
        Vendor vendor = vendors.findById(vendorId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Vendor not found"));
        MenuItem item = new MenuItem();
        item.setVendor(vendor);
        item.setItemName(req.itemName().trim());
        item.setPrice(req.price());
        item.setAvailable(req.available() == null || req.available());
        return MenuItemResponse.from(items.save(item));
    }

    @Transactional
    public MenuItemResponse update(Integer vendorId, Integer itemId, MenuItemRequest req) {
        MenuItem item = owned(vendorId, itemId);
        item.setItemName(req.itemName().trim());
        item.setPrice(req.price());
        if (req.available() != null) {
            item.setAvailable(req.available());
        }
        return MenuItemResponse.from(item);
    }

    @Transactional
    public MenuItemResponse setAvailability(Integer vendorId, Integer itemId, boolean available) {
        MenuItem item = owned(vendorId, itemId);
        item.setAvailable(available);
        return MenuItemResponse.from(item);
    }

    @Transactional
    public DeleteResult delete(Integer vendorId, Integer itemId) {
        MenuItem item = owned(vendorId, itemId);
        // Past orders reference this item, and sales history must be kept (blueprint Part 3-B),
        // so hide it instead of deleting it.
        if (orderItems.existsByMenuItemId(itemId)) {
            item.setAvailable(false);
            return new DeleteResult(false,
                    "Item has past orders, so it was marked unavailable instead of deleted");
        }
        items.delete(item);
        return new DeleteResult(true, "Menu item deleted");
    }

    /** Only finds the item if it belongs to this vendor; someone else's item looks like it doesn't exist. */
    private MenuItem owned(Integer vendorId, Integer itemId) {
        return items.findByIdAndVendorId(itemId, vendorId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Menu item not found"));
    }
}