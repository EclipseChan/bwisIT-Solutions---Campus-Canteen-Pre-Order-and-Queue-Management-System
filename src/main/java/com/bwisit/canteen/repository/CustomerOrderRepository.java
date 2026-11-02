package com.bwisit.canteen.repository;

import com.bwisit.canteen.entity.CustomerOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CustomerOrderRepository extends JpaRepository<CustomerOrder, Integer> {
    List<CustomerOrder> findByStudentIdOrderByOrderDateDesc(Integer studentId);
    List<CustomerOrder> findByVendorIdAndStatusIn(Integer vendorId, List<String> statuses);
}
