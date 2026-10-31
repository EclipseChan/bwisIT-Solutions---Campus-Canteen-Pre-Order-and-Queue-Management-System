package com.bwisit.canteen.dto;

import jakarta.validation.constraints.NotNull;

public record AvailabilityRequest(@NotNull Boolean available) {
}