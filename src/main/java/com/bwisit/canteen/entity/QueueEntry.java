package com.bwisit.canteen.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;

@Entity
@Table(name = "queue_entry")
@Getter @Setter
public class QueueEntry {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "queue_id")
    private Integer id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id", nullable = false, unique = true)
    private CustomerOrder order;

    @Column(name = "queue_number", nullable = false)
    private Integer queueNumber;

    @Column(name = "queue_date", nullable = false)
    private LocalDate queueDate = LocalDate.now();

    // waiting, called, served
    @Column(nullable = false, length = 20)
    private String status = "waiting";
}
