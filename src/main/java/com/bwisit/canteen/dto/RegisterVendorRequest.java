package com.bwisit.canteen.dto;

import jakarta.validation.constraints.*;

public record RegisterVendorRequest(
        @NotBlank @Size(max = 100) String vendorName,
        @Size(max = 20) String contactNumber,
        @NotBlank @Email @Size(max = 150) String email,
        @NotBlank @Size(min = 8, max = 72, message = "must be 8 to 72 characters") String password) {
}