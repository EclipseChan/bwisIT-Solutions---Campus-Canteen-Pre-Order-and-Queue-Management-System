package com.bwisit.canteen.security;

/** The logged-in user, rebuilt from the JWT on each request. role is STUDENT, VENDOR or ADMIN. */
public record AuthUser(Integer id, String email, String role) {
}