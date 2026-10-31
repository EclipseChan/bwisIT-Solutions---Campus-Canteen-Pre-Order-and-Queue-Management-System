package com.bwisit.canteen.repository;

import com.bwisit.canteen.entity.Vendor;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface VendorRepository extends JpaRepository<Vendor, Integer> {
    List<Vendor> findByActiveTrue();
    Optional<Vendor> findByEmail(String email);
    boolean existsByEmail(String email);
}