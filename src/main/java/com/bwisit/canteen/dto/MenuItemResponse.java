package com.bwisit.canteen.dto;

import com.bwisit.canteen.entity.MenuItem;
import java.math.BigDecimal;

public record MenuItemResponse(Integer id, String itemName, BigDecimal price, boolean available) {
    public static MenuItemResponse from(MenuItem m) {
        return new MenuItemResponse(m.getId(), m.getItemName(), m.getPrice(), m.isAvailable());
    }
}
