package com.bwisit.canteen.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "vendor")
@Getter @Setter
public class Vendor {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "vendor_id")
    private Integer id;

    @Column(name = "vendor_name", nullable = false, length = 100)
    private String vendorName;

    @Column(name = "contact_number", length = 20)
    private String contactNumber;

    @Column(unique = true, length = 150)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;
}
