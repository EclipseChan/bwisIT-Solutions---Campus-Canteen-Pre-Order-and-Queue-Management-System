package com.bwisit.canteen.service;

import com.bwisit.canteen.dto.*;
import com.bwisit.canteen.entity.*;
import com.bwisit.canteen.exception.ApiException;
import com.bwisit.canteen.repository.*;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.*;

@Service
public class OrderService {
    private static final ZoneId PH = ZoneId.of("Asia/Manila");

    /** Blueprint Rule 7: status only moves forward; cancelled is allowed any time before completion. */
    private static final Map<String, Set<String>> NEXT = Map.of(
            "pending", Set.of("preparing", "cancelled"),
            "preparing", Set.of("ready", "cancelled"),
            "ready", Set.of("completed", "cancelled"),
            "completed", Set.of(),
            "cancelled", Set.of());
    private static final List<String> ACTIVE = List.of("pending", "preparing", "ready");

    private final StudentRepository students;
    private final VendorRepository vendors;
    private final MenuItemRepository menuItems;
    private final CustomerOrderRepository orders;
    private final QueueEntryRepository queues;
    private final NotificationRepository notifications;

    @PersistenceContext
    private EntityManager em;

    public OrderService(StudentRepository students, VendorRepository vendors, MenuItemRepository menuItems,
                        CustomerOrderRepository orders, QueueEntryRepository queues,
                        NotificationRepository notifications) {
        this.students = students;
        this.vendors = vendors;
        this.menuItems = menuItems;
        this.orders = orders;
        this.queues = queues;
        this.notifications = notifications;
    }

    // ---------------------------------------------------------------- student side

    /** Runs in one transaction: if anything fails, nothing is saved. */
    @Transactional
    public OrderResponse place(Integer studentId, PlaceOrderRequest req) {
        Student student = students.findById(studentId)
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Account no longer exists"));
        Vendor vendor = vendors.findById(req.vendorId()).filter(Vendor::isActive)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND,
                        "Vendor not found or not accepting orders"));

        if (req.pickupTime().isBefore(LocalTime.now(PH))) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Pickup time must be later than now");
        }

        // Merge repeated items into one line, then load them all at once
        Map<Integer, Integer> wanted = new LinkedHashMap<>();
        for (OrderLineRequest line : req.items()) {
            wanted.merge(line.itemId(), line.quantity(), Integer::sum);
        }
        Map<Integer, MenuItem> found = new HashMap<>();
        menuItems.findAllById(wanted.keySet()).forEach(m -> found.put(m.getId(), m));

        CustomerOrder order = new CustomerOrder();
        order.setStudent(student);
        order.setVendor(vendor);
        order.setPickupTime(req.pickupTime());
        order.setOrderDate(LocalDateTime.now(PH));

        for (Map.Entry<Integer, Integer> e : wanted.entrySet()) {
            MenuItem item = found.get(e.getKey());
            // Rule 2: an order belongs to exactly one vendor
            if (item == null || !item.getVendor().getId().equals(vendor.getId())) {
                throw new ApiException(HttpStatus.BAD_REQUEST,
                        "Item " + e.getKey() + " is not on this vendor's menu");
            }
            if (!item.isAvailable()) {
                throw new ApiException(HttpStatus.BAD_REQUEST, item.getItemName() + " is currently unavailable");
            }
            OrderItem line = new OrderItem();
            line.setOrder(order);
            line.setMenuItem(item);
            line.setQuantity(e.getValue());
            line.setPriceAtOrder(item.getPrice()); // price locked in at order time
            order.getItems().add(line);
        }
        orders.save(order);

        QueueEntry queue = assignQueueNumber(order);
        notify(order, "Order #" + order.getId() + " placed. Your queue number is " + queue.getQueueNumber() + ".");
        return toResponse(order, queue);
    }

    @Transactional(readOnly = true)
    public List<OrderResponse> listForStudent(Integer studentId) {
        return orders.findByStudentIdOrderByOrderDateDesc(studentId).stream().map(this::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public OrderResponse getForStudent(Integer studentId, Integer orderId) {
        return toResponse(orders.findByIdAndStudentId(orderId, studentId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Order not found")));
    }

    /** Students may only cancel before the stall starts preparing the order. */
    @Transactional
    public OrderResponse cancelAsStudent(Integer studentId, Integer orderId) {
        CustomerOrder order = orders.findByIdAndStudentId(orderId, studentId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Order not found"));
        if (!"pending".equals(order.getStatus())) {
            throw new ApiException(HttpStatus.CONFLICT, "Only pending orders can be cancelled");
        }
        transition(order, "cancelled");
        return toResponse(order);
    }

    // ---------------------------------------------------------------- vendor side

    /** With no status given, returns the active queue (pending, preparing, ready), oldest first. */
    @Transactional(readOnly = true)
    public List<OrderResponse> listForVendor(Integer vendorId, String status) {
        List<String> statuses = ACTIVE;
        if (status != null && !status.isBlank()) {
            String s = status.trim().toLowerCase();
            if (!NEXT.containsKey(s)) {
                throw new ApiException(HttpStatus.BAD_REQUEST, "Unknown status: " + status);
            }
            statuses = List.of(s);
        }
        return orders.findByVendorIdAndStatusInOrderByOrderDateAsc(vendorId, statuses).stream()
                .map(this::toResponse).toList();
    }

    @Transactional
    public OrderResponse updateStatusAsVendor(Integer vendorId, Integer orderId, String newStatus) {
        CustomerOrder order = orders.findByIdAndVendorId(orderId, vendorId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Order not found"));
        String next = newStatus.trim().toLowerCase();
        if (!NEXT.containsKey(next)) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Unknown status: " + newStatus);
        }
        transition(order, next);
        return toResponse(order);
    }

    // ---------------------------------------------------------------- internals

    private void transition(CustomerOrder order, String next) {
        String current = order.getStatus();
        if (!NEXT.getOrDefault(current, Set.of()).contains(next)) {
            throw new ApiException(HttpStatus.CONFLICT,
                    "Cannot change an order from '" + current + "' to '" + next + "'");
        }
        order.setStatus(next);

        Optional<QueueEntry> queue = queues.findByOrderId(order.getId());
        queue.ifPresent(q -> {
            if ("ready".equals(next)) q.setStatus("called");
            if ("completed".equals(next)) q.setStatus("served");
        });

        String num = queue.map(q -> String.valueOf(q.getQueueNumber())).orElse("-");
        String id = "Order #" + order.getId();
        notify(order, switch (next) {
            case "preparing" -> id + " is now being prepared.";
            case "ready" -> id + " is ready for pickup! Queue number " + num + ".";
            case "completed" -> id + " is completed. Thank you!";
            default -> id + " was cancelled.";
        });
    }

    /**
     * Queue numbers are unique per day (blueprint Rule 6). A PostgreSQL advisory lock makes
     * simultaneous orders take turns, so two students can never read the same highest number.
     * The lock is released automatically when the transaction ends; the UNIQUE constraint
     * remains as the backstop.
     */
    private QueueEntry assignQueueNumber(CustomerOrder order) {
        LocalDate today = LocalDate.now(PH);
        em.createNativeQuery("select count(*) from (select pg_advisory_xact_lock(:k)) t")
                .setParameter("k", today.toEpochDay())
                .getSingleResult();

        QueueEntry queue = new QueueEntry();
        queue.setOrder(order);
        queue.setQueueDate(today);
        queue.setQueueNumber(queues.findMaxQueueNumber(today) + 1);
        return queues.save(queue);
    }

    private void notify(CustomerOrder order, String message) {
        Notification n = new Notification();
        n.setOrder(order);
        n.setMessage(message);
        n.setSentAt(LocalDateTime.now(PH));
        notifications.save(n);
    }

    private OrderResponse toResponse(CustomerOrder order) {
        return toResponse(order, queues.findByOrderId(order.getId()).orElse(null));
    }

    private OrderResponse toResponse(CustomerOrder order, QueueEntry queue) {
        List<OrderLineResponse> lines = new ArrayList<>();
        BigDecimal total = BigDecimal.ZERO;
        for (OrderItem oi : order.getItems()) {
            BigDecimal subtotal = oi.getPriceAtOrder().multiply(BigDecimal.valueOf(oi.getQuantity()));
            total = total.add(subtotal);
            lines.add(new OrderLineResponse(oi.getMenuItem().getId(), oi.getMenuItem().getItemName(),
                    oi.getQuantity(), oi.getPriceAtOrder(), subtotal));
        }
        long ahead = 0;
        if (queue != null && ("pending".equals(order.getStatus()) || "preparing".equals(order.getStatus()))) {
            ahead = queues.countAhead(queue.getQueueDate(), queue.getQueueNumber(), order.getVendor().getId());
        }
        return new OrderResponse(order.getId(), order.getVendor().getId(), order.getVendor().getVendorName(),
                order.getStudent().getFullName(), order.getOrderDate(), order.getPickupTime(), order.getStatus(),
                queue == null ? null : queue.getQueueNumber(), queue == null ? null : queue.getQueueDate(),
                ahead, lines, total);
    }
}
