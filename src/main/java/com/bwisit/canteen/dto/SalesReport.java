package com.bwisit.canteen.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record SalesReport(LocalDate from, LocalDate to,
                          long totalOrders, long completedOrders, long cancelledOrders,
                          BigDecimal revenue, BigDecimal averageOrderValue,
                          List<TopItem> topItems, List<DailySales> daily, List<VendorSales> byVendor) {

    public record TopItem(String itemName, long quantitySold, BigDecimal revenue) {
    }

    public record DailySales(LocalDate date, long orders, BigDecimal revenue) {
    }

    public record VendorSales(Integer vendorId, String vendorName, long orders, BigDecimal revenue) {
    }
}
