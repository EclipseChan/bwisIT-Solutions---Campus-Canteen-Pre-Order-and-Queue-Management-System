package com.bwisit.canteen.controller;

import com.bwisit.canteen.dto.*;
import com.bwisit.canteen.security.AuthUser;
import com.bwisit.canteen.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService auth;

    public AuthController(AuthService auth) {
        this.auth = auth;
    }

    @PostMapping("/register/student")
    @ResponseStatus(HttpStatus.CREATED)
    public AuthResponse registerStudent(@Valid @RequestBody RegisterStudentRequest req) {
        return auth.registerStudent(req);
    }

    @PostMapping("/register/vendor")
    @ResponseStatus(HttpStatus.CREATED)
    public AuthResponse registerVendor(@Valid @RequestBody RegisterVendorRequest req) {
        return auth.registerVendor(req);
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest req) {
        return auth.login(req);
    }

    /** Returns who the token belongs to; handy for testing and for the React client. */
    @GetMapping("/me")
    public AuthUser me(@AuthenticationPrincipal AuthUser user) {
        return user;
    }
}