package com.bwisit.canteen.dto;

import com.bwisit.canteen.entity.Vendor;

public record VendorResponse(Integer id, String vendorName, String contactNumber, boolean active) {
    public static VendorResponse from(Vendor v) {
        return new VendorResponse(v.getId(), v.getVendorName(), v.getContactNumber(), v.isActive());
    }
}
