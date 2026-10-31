package com.bwisit.canteen.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;

@Entity
@Table(name = "menu_item")
@Getter @Setter
public class MenuItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "item_id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "vendor_id", nullable = false)
    private Vendor vendor;

    @Column(name = "item_name", nullable = false, length = 100)
    private String itemName;

    @Column(nullable = false, precision = 8, scale = 2)
    private BigDecimal price;

    @Column(name = "is_available", nullable = false)
    private boolean available = true;
}
