package com.bwisit.canteen.service;

import com.bwisit.canteen.dto.SalesReport;
import com.bwisit.canteen.dto.SalesReport.DailySales;
import com.bwisit.canteen.dto.SalesReport.TopItem;
import com.bwisit.canteen.dto.SalesReport.VendorSales;
import com.bwisit.canteen.exception.ApiException;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;

/** Revenue and demand figures count completed orders only. Past data is never deleted, so history stays reportable. */
@Service
public class ReportService {
    private static final ZoneId PH = ZoneId.of("Asia/Manila");
    private static final String RANGE = " o.order_date >= :s and o.order_date < :e";

    @PersistenceContext
    private EntityManager em;

    /** vendorId null means the whole canteen (admin view). Defaults to the last 30 days. */
    @Transactional(readOnly = true)
    public SalesReport build(Integer vendorId, LocalDate from, LocalDate to) {
        if (to == null) to = LocalDate.now(PH);
        if (from == null) from = to.minusDays(29);
        if (from.isAfter(to)) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "'from' must not be after 'to'");
        }
        LocalDateTime start = from.atStartOfDay();
        LocalDateTime end = to.plusDays(1).atStartOfDay();
        String vf = vendorId == null ? "" : " and o.vendor_id = :vid";

        Query q = em.createNativeQuery(
                "select count(*) filter (where o.status = 'completed'), "
              + "count(*) filter (where o.status = 'cancelled'), count(*) "
              + "from customer_order o where" + RANGE + vf);
        Object[] counts = (Object[]) bind(q, start, end, vendorId).getSingleResult();
        long completed = num(counts[0]);
        long cancelled = num(counts[1]);
        long total = num(counts[2]);

        q = em.createNativeQuery(
                "select coalesce(sum(oi.price_at_order * oi.quantity), 0) from order_item oi "
              + "join customer_order o on o.order_id = oi.order_id "
              + "where o.status = 'completed' and" + RANGE + vf);
        BigDecimal revenue = money(bind(q, start, end, vendorId).getSingleResult());
        BigDecimal average = completed == 0 ? BigDecimal.ZERO
                : revenue.divide(BigDecimal.valueOf(completed), 2, RoundingMode.HALF_UP);

        q = em.createNativeQuery(
                "select m.item_name, sum(oi.quantity), sum(oi.price_at_order * oi.quantity) "
              + "from order_item oi join customer_order o on o.order_id = oi.order_id "
              + "join menu_item m on m.item_id = oi.item_id "
              + "where o.status = 'completed' and" + RANGE + vf
              + " group by m.item_id, m.item_name order by sum(oi.quantity) desc, m.item_name limit 10");
        List<TopItem> top = new ArrayList<>();
        for (Object r : bind(q, start, end, vendorId).getResultList()) {
            Object[] row = (Object[]) r;
            top.add(new TopItem((String) row[0], num(row[1]), money(row[2])));
        }

        q = em.createNativeQuery(
                "select cast(o.order_date as date), count(distinct o.order_id), "
              + "coalesce(sum(oi.price_at_order * oi.quantity), 0) "
              + "from customer_order o join order_item oi on oi.order_id = o.order_id "
              + "where o.status = 'completed' and" + RANGE + vf
              + " group by cast(o.order_date as date) order by 1");
        List<DailySales> daily = new ArrayList<>();
        for (Object r : bind(q, start, end, vendorId).getResultList()) {
            Object[] row = (Object[]) r;
            daily.add(new DailySales(LocalDate.parse(String.valueOf(row[0])), num(row[1]), money(row[2])));
        }

        List<VendorSales> byVendor = new ArrayList<>();
        if (vendorId == null) {
            q = em.createNativeQuery(
                    "select v.vendor_id, v.vendor_name, count(distinct o.order_id), "
                  + "coalesce(sum(oi.price_at_order * oi.quantity), 0) from vendor v "
                  + "left join customer_order o on o.vendor_id = v.vendor_id and o.status = 'completed' "
                  + "and o.order_date >= :s and o.order_date < :e "
                  + "left join order_item oi on oi.order_id = o.order_id "
                  + "group by v.vendor_id, v.vendor_name order by 4 desc, v.vendor_name");
            for (Object r : bind(q, start, end, null).getResultList()) {
                Object[] row = (Object[]) r;
                byVendor.add(new VendorSales(((Number) row[0]).intValue(), (String) row[1],
                        num(row[2]), money(row[3])));
            }
        }

        return new SalesReport(from, to, total, completed, cancelled, revenue, average, top, daily, byVendor);
    }

    private Query bind(Query q, LocalDateTime start, LocalDateTime end, Integer vendorId) {
        q.setParameter("s", start);
        q.setParameter("e", end);
        if (vendorId != null) {
            q.setParameter("vid", vendorId);
        }
        return q;
    }

    private long num(Object o) {
        return o == null ? 0 : ((Number) o).longValue();
    }

    private BigDecimal money(Object o) {
        return o == null ? BigDecimal.ZERO : new BigDecimal(String.valueOf(o));
    }
}
