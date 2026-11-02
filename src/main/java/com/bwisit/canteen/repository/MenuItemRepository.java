package com.bwisit.canteen.repository;

import com.bwisit.canteen.entity.MenuItem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface MenuItemRepository extends JpaRepository<MenuItem, Integer> {
    List<MenuItem> findByVendorIdAndAvailableTrue(Integer vendorId);
    List<MenuItem> findByVendorIdOrderByItemNameAsc(Integer vendorId);
    Optional<MenuItem> findByIdAndVendorId(Integer id, Integer vendorId);
}