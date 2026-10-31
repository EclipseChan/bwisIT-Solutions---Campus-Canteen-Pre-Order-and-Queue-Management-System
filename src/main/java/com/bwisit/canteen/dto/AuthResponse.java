package com.bwisit.canteen.dto;

public record AuthResponse(String token, String role, Integer id, String name) {
}