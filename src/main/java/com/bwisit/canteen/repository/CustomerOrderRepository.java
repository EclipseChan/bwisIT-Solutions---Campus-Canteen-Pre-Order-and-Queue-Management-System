package com.bwisit.canteen.repository;

import com.bwisit.canteen.entity.CustomerOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface CustomerOrderRepository extends JpaRepository<CustomerOrder, Integer> {
    List<CustomerOrder> findByStudentIdOrderByOrderDateDesc(Integer studentId);
    List<CustomerOrder> findByVendorIdAndStatusInOrderByOrderDateAsc(Integer vendorId, List<String> statuses);
    Optional<CustomerOrder> findByIdAndStudentId(Integer id, Integer studentId);
    Optional<CustomerOrder> findByIdAndVendorId(Integer id, Integer vendorId);
}
