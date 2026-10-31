package com.bwisit.canteen.repository;

import com.bwisit.canteen.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderItemRepository extends JpaRepository<OrderItem, Integer> {
    boolean existsByMenuItemId(Integer itemId);
}