# Backend endpoints

Base URL `http://localhost:8080`. Send `Authorization: Bearer <token>` on protected routes.
The token comes from the register or login response.

| Method and path | Role | Purpose |
|---|---|---|
| POST `/api/auth/register/student` | public | Register a student (`fullName`, `email`, `password` of 8 to 72 characters) |
| POST `/api/auth/register/vendor` | public | Register a vendor stall (`vendorName`, `email`, `password`) |
| POST `/api/auth/login` | public | Log in with `email` and `password` |
| GET `/api/auth/me` | any logged in | Who the token belongs to |
| GET `/api/vendors` | public | Active stalls |
| GET `/api/vendors/{vendorId}/menu` | public | A stall's menu |
| POST `/api/orders` | student | Place an order (`vendorId`, `pickupTime`, `items`); returns queue number |
| GET `/api/orders`, GET `/api/orders/{orderId}` | student | Own orders |
| POST `/api/orders/{orderId}/cancel` | student | Cancel while pending |
| GET `/api/notifications` | student | Own notifications |
| GET `/api/notifications/unread-count` | student | Unread count |
| PATCH `/api/notifications/{id}/read` | student | Mark as read |
| GET, POST `/api/vendor/menu` | vendor | List or add own menu items |
| PUT `/api/vendor/menu/{itemId}` | vendor | Edit an item |
| PATCH `/api/vendor/menu/{itemId}/availability` | vendor | Show or hide an item |
| DELETE `/api/vendor/menu/{itemId}` | vendor | Delete, or hide if it has past orders |
| GET `/api/vendor/orders` | vendor | Incoming orders (active by default) |
| PATCH `/api/vendor/orders/{orderId}/status` | vendor | Move an order forward (`status`) |
| GET `/api/vendor/reports/sales` | vendor | Own sales, optional `from` and `to` (yyyy-MM-dd) |
| GET `/api/admin/vendors` | admin | All stalls, including switched-off ones |
| PATCH `/api/admin/vendors/{vendorId}/active` | admin | Switch a stall on or off (`active`) |
| GET `/api/admin/reports/sales` | admin | Canteen-wide sales with per-vendor breakdown |

Example:

```powershell
$body = @{ fullName = "Test Student"; email = "t@school.edu"; password = "password123" } | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/auth/register/student" `
    -ContentType "application/json" -Body $body
```
