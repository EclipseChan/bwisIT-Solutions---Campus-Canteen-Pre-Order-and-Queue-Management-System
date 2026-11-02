package com.bwisit.canteen.repository;

import com.bwisit.canteen.entity.QueueEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.time.LocalDate;

public interface QueueEntryRepository extends JpaRepository<QueueEntry, Integer> {
    @Query("select coalesce(max(q.queueNumber), 0) from QueueEntry q where q.queueDate = :date")
    int findMaxQueueNumber(LocalDate date);
}
