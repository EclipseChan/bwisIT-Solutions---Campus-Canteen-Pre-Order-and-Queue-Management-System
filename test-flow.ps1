# End-to-end smoke test. Start the app first (F5 in VS Code), then run from this folder:
#   powershell -ExecutionPolicy Bypass -File .\test-flow.ps1
# It creates a fresh vendor and student each run (random emails), so it is safe to repeat.
# Note: the pickup time is 23:59, so run it before midnight Philippine time.

$base = "http://localhost:8080/api"
$id = Get-Date -Format "HHmmss"

function Call($method, $path, $body = $null, $token = $null) {
    $h = @{}
    if ($token) { $h["Authorization"] = "Bearer $token" }
    $p = @{ Method = $method; Uri = "$base$path"; Headers = $h; ContentType = "application/json" }
    if ($body) { $p.Body = ConvertTo-Json -InputObject $body -Depth 6 }
    Invoke-RestMethod @p
}
function Show($title, $obj) { Write-Host "`n=== $title ===" -ForegroundColor Cyan; $obj | ConvertTo-Json -Depth 6 }

$v = Call Post "/auth/register/vendor" @{ vendorName = "Stall $id"; email = "v$id@test.edu"; password = "password123" }
$s = Call Post "/auth/register/student" @{ fullName = "Student $id"; email = "s$id@test.edu"; password = "password123" }
Write-Host "Registered vendor id $($v.id) and student id $($s.id)" -ForegroundColor Green

$i1 = Call Post "/vendor/menu" @{ itemName = "Tapsilog"; price = 85 } $v.token
$i2 = Call Post "/vendor/menu" @{ itemName = "Siomai"; price = 45.5 } $v.token
Show "Public menu" (Call Get "/vendors/$($v.id)/menu")

$o1 = Call Post "/orders" @{ vendorId = $v.id; pickupTime = "23:59"; items = @( @{ itemId = $i1.id; quantity = 2 }, @{ itemId = $i2.id; quantity = 1 } ) } $s.token
$o2 = Call Post "/orders" @{ vendorId = $v.id; pickupTime = "23:59"; items = @( @{ itemId = $i2.id; quantity = 3 } ) } $s.token
Show "Order 1 (queue number, total, people ahead)" $o1
Write-Host "Order 2 got queue number $($o2.queueNumber), people ahead: $($o2.peopleAhead)" -ForegroundColor Green

Show "Vendor's incoming orders" (Call Get "/vendor/orders" $null $v.token)

Call Patch "/vendor/orders/$($o1.orderId)/status" @{ status = "preparing" } $v.token | Out-Null
Call Patch "/vendor/orders/$($o1.orderId)/status" @{ status = "ready" } $v.token | Out-Null
$done = Call Patch "/vendor/orders/$($o1.orderId)/status" @{ status = "completed" } $v.token
Write-Host "`nOrder 1 final status: $($done.status)" -ForegroundColor Green

$cancelled = Call Post "/orders/$($o2.orderId)/cancel" $null $s.token
Write-Host "Order 2 after student cancel: $($cancelled.status)" -ForegroundColor Green

try { Call Patch "/vendor/orders/$($o1.orderId)/status" @{ status = "pending" } $v.token | Out-Null }
catch { Write-Host "Going backwards was correctly rejected (409)" -ForegroundColor Green }

Show "Student's notifications" (Call Get "/notifications" $null $s.token)
Show "Vendor sales report" (Call Get "/vendor/reports/sales" $null $v.token)
Write-Host "`nAll steps ran." -ForegroundColor Green
