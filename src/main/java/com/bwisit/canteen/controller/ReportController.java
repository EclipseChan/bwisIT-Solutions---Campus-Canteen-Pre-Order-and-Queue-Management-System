package com.bwisit.canteen.controller;

import com.bwisit.canteen.dto.SalesReport;
import com.bwisit.canteen.security.AuthUser;
import com.bwisit.canteen.service.ReportService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;

@RestController
@RequestMapping("/api")
public class ReportController {
    private final ReportService reports;

    public ReportController(ReportService reports) {
        this.reports = reports;
    }

    /** A vendor's own sales and popular items. Dates are yyyy-MM-dd; default is the last 30 days. */
    @GetMapping("/vendor/reports/sales")
    public SalesReport vendorSales(@AuthenticationPrincipal AuthUser user,
                                   @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                   @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return reports.build(user.id(), from, to);
    }

    /** Whole-canteen report with a per-vendor breakdown. */
    @GetMapping("/admin/reports/sales")
    public SalesReport adminSales(@RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                  @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return reports.build(null, from, to);
    }
}
