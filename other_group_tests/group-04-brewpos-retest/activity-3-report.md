# Activity 3 — Installation and run

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Scope:** Fresh copy of the submitted archive; Maven Wrapper build and full test suite; one Java-debugger launch attempt from the confirmed project root; every `TESTING_GUIDE.md` browser flow; fresh screenshots. This is not a source-code review or a production deployment.  
**Environment:** Windows; Temurin OpenJDK 21.0.13; PostgreSQL 18.6 on an isolated loopback cluster (`127.0.0.1:55457`); app on `http://127.0.0.1:18080`; test-only credentials. No application source was edited.

## Results

| Check | Result |
|---|---|
| Database setup | **PASS** — supplied `schema.sql`, `seed.sql`, and `05_create_app_role.sql` loaded into a disposable database (`grp_brewposdb`); app-role login verified. |
| Build via Maven Wrapper | **PASS** — `BUILD SUCCESS`; packaged `target/brewpos-0.0.1-SNAPSHOT.jar` = 52,969,686 bytes. |
| Automated tests | **PASS** — **19 tests, 0 failures, 0 errors, 0 skipped** (1 + 9 + 8 + 1 by class). |
| Application start | **PASS** — `Started BrewPosApplication in 9.094 seconds`; Tomcat listening on port 18080. |
| Java debugger launch from project root | **NOT FULLY VERIFIED** — a CLI Java debugger attached, but the IDE debugger launch and a halted breakpoint were not confirmed. See issue 1. |
| UI flows in `TESTING_GUIDE.md` | **PASS** — all listed flows exercised against the running app. |
| Fresh screenshots | **PASS** — 5 new captures; no prior screenshots reused. |

### Test breakdown

| Test class | Tests | Failures | Errors | Skipped |
|---|---:|---:|---:|---:|
| `BrewPosApplicationTests` | 1 | 0 | 0 | 0 |
| `BrewPosControllerTests` | 9 | 0 | 0 | 0 |
| `BrewPosServiceTests` | 8 | 0 | 0 | 0 |
| `OrderRollbackTests` | 1 | 0 | 0 | 0 |
| **Total** | **19** | **0** | **0** | **0** |

## UI and behaviour observed

| `TESTING_GUIDE.md` flow | Observed result |
|---|---|
| Register loads seeded menu and staff | PASS — categories `All Items`, `Coffee`, `Non-Coffee`, `Pastries`; 10 active tiles; inactive `Pumpkin Spice Latte` not shown; staff `Demo Cashier` and `Demo Manager` available. |
| Cashier vs manager view | PASS — cashier Menu shows a read-only notice, hides add/edit forms and action buttons. |
| Add category and reload | PASS — `Tea Specials` persisted after `F5`. |
| Add menu item | PASS — `Hojicha Latte`, category `Tea Specials`, price `115.00`, Active. |
| Deactivate / reactivate | PASS — deactivation removed it from Register (10 tiles); reactivation restored it (11 tiles). |
| Cash order and duplicate-line merging | PASS — order #10: two `Hojicha Latte` clicks merged into **one row, quantity 2**; `Butter Croissant` ×1; total `305.50`; receipt matched. |
| Receipt sold-price preservation | PASS — after editing the menu price to `150.00`, order #10's receipt still showed unit `115.00` and total `305.50`. |
| Online order | PASS — order #11: `Hojicha Latte` ×1 at `150.00`, payment method `ONLINE`. |
| Order filters | PASS — today = 5 rows, all = 7 rows; seeded order #3 (`13:05:00`) sorted above the new orders. |
| Daily sales | PASS — net `1371.00` across 5 orders; Cash 3 orders / `921.00`, Online 2 / `450.00`; matched direct SQL. |
| Validation | PASS — empty cart shows `Tap items on the menu to build an order` and disables **Charge**; duplicate category `Coffee` rejected with `A category named 'Coffee' already exists`. |

Database evidence after the UI run: `staff=2`, `menu_category=4`, `menu_item=12`, `order_ticket=7`, `order_line_item=12`. Order #10 is `CASH` with lines `75.50` and `230.00`; order #11 is `ONLINE` at `150.00`; `Hojicha Latte` ended at `150.00`, Active.

## Issues and blockers

1. **IDE debugger launch unverified (tooling limitation, not an app failure).** The project-root workspace was confirmed (`pom.xml` present); no debug session was active and no `.vscode/launch.json` existed. Java Language Support (`redhat.java 1.58.0`) and Debugger for Java (`vscjava.vscode-java-debug 0.60.0`) were installed. This CLI harness has no way to drive the VS Code debug UI; the reproducible path was `jdb`, which attached via `com.sun.jdi.SocketAttach` to `127.0.0.1:5005`. The deferred `com.brewpos.BrewPosApplication.main` breakpoint never halted because the VM had been started with `suspend=n` and `main` had already executed. Breakpoint/IDE-launch evidence is therefore inconclusive. The app itself demonstrably starts; **this must not be read as an application startup failure**.
2. **The app used for the UI flows was the packaged JAR started with JDWP enabled.** This proves the application runs, but it does not substitute for a verified IDE debugger launch.
3. **In-app screenshot tool failure.** Later in-app captures failed with a visibility error; screens 02–05 were captured with headless Edge instead. Screenshot 01 was captured from the in-app browser session.
4. **Isolation.** An unrelated instance already ran on port 8081; it was left untouched. All testing above used only the retest app on 18080 and the retest cluster on 55457.

## Verdict

The application installs, builds, passes all 19 tests, starts, and satisfies every tested UI flow. Because the prescribed **IDE debugger launch and breakpoint hit remain unverified**, the activity is **Passed with issues** rather than **Pass**. The issue is confined to debugger tooling; no application failure was observed.

## Evidence

- Test run (19 tests): [`evidence/activity3-mvn-test.log`](evidence/activity3-mvn-test.log)
- Package build: [`evidence/activity3-mvn-package.log`](evidence/activity3-mvn-package.log)
- App startup log: [`evidence/activity3-app-debug.out.log`](evidence/activity3-app-debug.out.log)
- Debugger attach attempt: [`evidence/activity3-jdb.log`](evidence/activity3-jdb.log)
- Database checks: [`evidence/activity3-db-checks.log`](evidence/activity3-db-checks.log)
- Database setup: [`evidence/01-schema.log`](evidence/01-schema.log), [`evidence/02-seed.log`](evidence/02-seed.log), [`evidence/03-app-role.log`](evidence/03-app-role.log), [`evidence/05-app-role-login.log`](evidence/05-app-role-login.log)
- Screenshots: [`evidence/screenshots/01-register-inapp.jpg`](evidence/screenshots/01-register-inapp.jpg), [`02-register-headless.png`](evidence/screenshots/02-register-headless.png), [`03-menu-cashier-headless.png`](evidence/screenshots/03-menu-cashier-headless.png), [`04-orders-headless.png`](evidence/screenshots/04-orders-headless.png), [`05-daily-sales-headless.png`](evidence/screenshots/05-daily-sales-headless.png)
