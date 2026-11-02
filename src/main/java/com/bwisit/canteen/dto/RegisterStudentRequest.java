package com.bwisit.canteen.dto;

import jakarta.validation.constraints.*;

public record RegisterStudentRequest(
        @NotBlank @Size(max = 100) String fullName,
        @NotBlank @Email @Size(max = 150) String email,
        @NotBlank @Size(min = 8, max = 72, message = "must be 8 to 72 characters") String password) {
}
