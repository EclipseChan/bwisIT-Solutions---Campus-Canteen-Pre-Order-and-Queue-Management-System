package com.bwisit.canteen.service;

import com.bwisit.canteen.dto.*;
import com.bwisit.canteen.entity.Student;
import com.bwisit.canteen.entity.Vendor;
import com.bwisit.canteen.exception.ApiException;
import com.bwisit.canteen.repository.StudentRepository;
import com.bwisit.canteen.repository.VendorRepository;
import com.bwisit.canteen.security.JwtService;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {
    private final StudentRepository students;
    private final VendorRepository vendors;
    private final PasswordEncoder encoder;
    private final JwtService jwt;

    public AuthService(StudentRepository students, VendorRepository vendors,
                       PasswordEncoder encoder, JwtService jwt) {
        this.students = students;
        this.vendors = vendors;
        this.encoder = encoder;
        this.jwt = jwt;
    }

    @Transactional
    public AuthResponse registerStudent(RegisterStudentRequest req) {
        String email = normalize(req.email());
        ensureEmailFree(email);
        Student s = new Student();
        s.setFullName(req.fullName().trim());
        s.setEmail(email);
        s.setPasswordHash(encoder.encode(req.password()));
        s = students.save(s);
        return new AuthResponse(jwt.generateToken(s.getId(), email, s.getRole()),
                s.getRole(), s.getId(), s.getFullName());
    }

    @Transactional
    public AuthResponse registerVendor(RegisterVendorRequest req) {
        String email = normalize(req.email());
        ensureEmailFree(email);
        Vendor v = new Vendor();
        v.setVendorName(req.vendorName().trim());
        v.setContactNumber(req.contactNumber());
        v.setEmail(email);
        v.setPasswordHash(encoder.encode(req.password()));
        v = vendors.save(v);
        return new AuthResponse(jwt.generateToken(v.getId(), email, "VENDOR"),
                "VENDOR", v.getId(), v.getVendorName());
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest req) {
        String email = normalize(req.email());

        var student = students.findByEmail(email);
        if (student.isPresent() && encoder.matches(req.password(), student.get().getPasswordHash())) {
            Student s = student.get();
            return new AuthResponse(jwt.generateToken(s.getId(), email, s.getRole()),
                    s.getRole(), s.getId(), s.getFullName());
        }

        var vendor = vendors.findByEmail(email);
        if (vendor.isPresent() && vendor.get().isActive() && vendor.get().getPasswordHash() != null
                && encoder.matches(req.password(), vendor.get().getPasswordHash())) {
            Vendor v = vendor.get();
            return new AuthResponse(jwt.generateToken(v.getId(), email, "VENDOR"),
                    "VENDOR", v.getId(), v.getVendorName());
        }

        // Same message for "no such email" and "wrong password" so accounts can't be probed
        throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid email or password");
    }

    private void ensureEmailFree(String email) {
        if (students.existsByEmail(email) || vendors.existsByEmail(email)) {
            throw new ApiException(HttpStatus.CONFLICT, "Email is already registered");
        }
    }

    private String normalize(String email) {
        return email.trim().toLowerCase();
    }
}
