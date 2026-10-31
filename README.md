# Campus Canteen Backend (Spring Boot)

Requires: JDK 21, Maven, PostgreSQL with the 7 tables from the blueprint.

## Run (Windows PowerShell)
```powershell
$env:DB_PASSWORD = "your-canteen_admin-password"
# optional: $env:DB_NAME = "your_real_db_name"
mvn spring-boot:run
```
Test: http://localhost:8080/api/vendors

Insert test data first (psql or pgAdmin):
```sql
INSERT INTO vendor (vendor_name, contact_number, is_active) VALUES ('Aling Nena''s Silog', '09171234567', true);
INSERT INTO menu_item (vendor_id, item_name, price, is_available) VALUES (1, 'Tapsilog', 85.00, true), (1, 'Longsilog', 75.00, true);
```
