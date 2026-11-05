# Activity 3 — BrewPOS installation report

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Device:** Windows; Java 21, included Maven Wrapper, PostgreSQL 18.6  
**Source:** `brewpos-main.zip`, extracted to a temporary test copy.

## Independent working-copy verification — 2026-11-05

The app was subsequently verified using the other AI's working copy. Its 85 non-runtime source files matched the attached `other_group_tests/brewpos-main` copy by SHA-256; local `.env`, `.pgdata`, build output, and logs were excluded. The running Java process was rooted at `C:\Users\Marcos\Documents\Default Project\brewpos-main`, on port 8081, with its isolated PostgreSQL cluster on port 5433. The app opened in the browser, and all Activity 3 flows in `TESTING_GUIDE.md` were exercised:

| Additional check | Result |
|---|---|
| Running app and database | PASS — BrewPOS loaded and performed database-backed reads/writes. |
| Menu persistence and manager/cashier view | PASS — `Tea Specials` and `Hojicha Latte` were present; cashier read-only behavior had been confirmed in the earlier browser check. |
| Deactivate/reactivate | PASS — deactivated `Hojicha Latte` disappeared from Register; reactivated item returned. |
| Cash order and duplicate-line merging | PASS — order #7 merged two Hojicha clicks into quantity 2, added one Butter Croissant, and totaled 305.50. Receipt preserved the 115.00 unit price. |
| Price-change receipt check | PASS — after changing the menu price to 150.00, order #7 still displayed the original 115.00 sold price. |
| Online order | PASS — order #8 recorded Hojicha Latte at 150.00 with Online payment. |
| Today/All order filters | PASS — Today showed 5 orders; All showed 7. |
| Daily sales | PASS — 1371.00 across 5 orders; Cash 921.00 / 3 orders and Online 450.00 / 2 orders. Values matched a read-only SQL query. |
| Empty-cart and duplicate-category validation | PASS — Charge remained disabled for an empty cart; duplicate `Coffee` was rejected. |
| Screenshot | PASS — a fresh Daily Sales screen capture was taken during this verification. |

This supersedes the earlier **not verified** app-start/browser result for the matching working copy. The IDE debugger launch and a breakpoint hit were not independently confirmed, so the overall status remains **Passed with issues**. No application source files were changed. The two test orders and manager-created menu data remain in this running local test instance.

## Earlier isolated rerun (historical; startup/browser result superseded above)

| Check | Result |
|---|---|
| Database setup | PASS — supplied schema and seed scripts loaded into a disposable local database. |
| Build and dependency resolution | PASS — Maven Wrapper completed the test build successfully on the rerun. |
| Automated tests | PASS — 19 tests, 0 failures, 0 errors, 0 skipped on the rerun. |
| Standalone app startup | NOT VERIFIED — after extracting the project under the current VS Code workspace and confirming no active debug session, the Java debugger timed out after 120 seconds without detecting a session. A one-time session check found no active session. |
| HTTP/browser checks/screenshots | NOT VERIFIED — opening `http://127.0.0.1:8081/` returned connection refused; no screenshot was captured. |

**Issue:** The successful build and full test suite confirm the project and its dependencies can be installed and tested on this device. Moving the temporary project under the current VS Code workspace resolved the earlier “workspace not found” condition, but the subsequent debugger launch still timed out without an active session. Because the browser could not connect, the app's ability to start remains unverified, not failed; the available evidence does not establish whether the remaining issue is in the debugger or application. No raw terminal launch or automatic debugger retry was used.

The test database used only loopback access and disposable test configuration. The disposable database and test `.env` were removed, and ports 55457 and 8081 are closed. The submitted source was not modified. A temporary archive/build copy remains under `other_group_tests/_temp-brewpos-rerun/`: Windows reported that the folder was in use during cleanup; the process holding it was not confirmed. The copy contains no `.env` or test credential and should be removed once the folder is released.
