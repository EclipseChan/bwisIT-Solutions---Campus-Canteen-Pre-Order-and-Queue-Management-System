package com.bwisit.canteen.controller;

import com.bwisit.canteen.dto.ActiveRequest;
import com.bwisit.canteen.dto.VendorResponse;
import com.bwisit.canteen.entity.Vendor;
import com.bwisit.canteen.exception.ApiException;
import com.bwisit.canteen.repository.VendorRepository;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/** Canteen administrator tools: see every vendor and switch stalls on or off. */
@RestController
@RequestMapping("/api/admin/vendors")
public class AdminController {
    private final VendorRepository vendors;

    public AdminController(VendorRepository vendors) {
        this.vendors = vendors;
    }

    @GetMapping
    public List<VendorResponse> all() {
        return vendors.findAll().stream().map(VendorResponse::from).toList();
    }

    @PatchMapping("/{vendorId}/active")
    public VendorResponse setActive(@PathVariable Integer vendorId, @Valid @RequestBody ActiveRequest req) {
        Vendor v = vendors.findById(vendorId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Vendor not found"));
        v.setActive(req.active());
        return VendorResponse.from(vendors.save(v));
    }
}
