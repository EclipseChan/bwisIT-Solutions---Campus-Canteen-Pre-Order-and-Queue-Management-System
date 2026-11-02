package com.bwisit.canteen.repository;

import com.bwisit.canteen.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface NotificationRepository extends JpaRepository<Notification, Integer> {
    List<Notification> findByOrder_Student_IdOrderBySentAtDesc(Integer studentId);
    List<Notification> findByOrder_Student_IdAndReadFalseOrderBySentAtDesc(Integer studentId);
    long countByOrder_Student_IdAndReadFalse(Integer studentId);
    Optional<Notification> findByIdAndOrder_Student_Id(Integer id, Integer studentId);
}
