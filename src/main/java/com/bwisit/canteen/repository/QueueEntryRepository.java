package com.bwisit.canteen.repository;

import com.bwisit.canteen.entity.QueueEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.time.LocalDate;
import java.util.Optional;

public interface QueueEntryRepository extends JpaRepository<QueueEntry, Integer> {
    @Query("select coalesce(max(q.queueNumber), 0) from QueueEntry q where q.queueDate = :date")
    int findMaxQueueNumber(LocalDate date);

    Optional<QueueEntry> findByOrderId(Integer orderId);

    /** Orders at the same stall, earlier in today's queue, still waiting or being prepared. */
    @Query("select count(q) from QueueEntry q where q.queueDate = :date and q.queueNumber < :number "
         + "and q.order.vendor.id = :vendorId and q.order.status in ('pending','preparing')")
    long countAhead(LocalDate date, Integer number, Integer vendorId);
}
