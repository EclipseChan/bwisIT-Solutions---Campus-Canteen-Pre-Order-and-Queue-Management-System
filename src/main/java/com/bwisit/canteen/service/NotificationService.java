package com.bwisit.canteen.service;

import com.bwisit.canteen.dto.NotificationResponse;
import com.bwisit.canteen.entity.Notification;
import com.bwisit.canteen.exception.ApiException;
import com.bwisit.canteen.repository.NotificationRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
public class NotificationService {
    private final NotificationRepository repo;

    public NotificationService(NotificationRepository repo) {
        this.repo = repo;
    }

    @Transactional(readOnly = true)
    public List<NotificationResponse> list(Integer studentId, boolean unreadOnly) {
        List<Notification> found = unreadOnly
                ? repo.findByOrder_Student_IdAndReadFalseOrderBySentAtDesc(studentId)
                : repo.findByOrder_Student_IdOrderBySentAtDesc(studentId);
        return found.stream().map(NotificationResponse::from).toList();
    }

    @Transactional(readOnly = true)
    public long unreadCount(Integer studentId) {
        return repo.countByOrder_Student_IdAndReadFalse(studentId);
    }

    @Transactional
    public NotificationResponse markRead(Integer studentId, Integer id) {
        Notification n = repo.findByIdAndOrder_Student_Id(id, studentId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Notification not found"));
        n.setRead(true);
        return NotificationResponse.from(n);
    }
}
