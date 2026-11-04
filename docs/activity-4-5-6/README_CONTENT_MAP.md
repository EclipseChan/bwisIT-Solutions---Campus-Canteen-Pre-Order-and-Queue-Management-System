# README Content Preservation Map

This map records where each heading, table, command set, warning, and linked reference from the original README is retained in the tester-first README. The reference material remains after the new tester path. No original project facts or test outcomes are asserted as new results.

| Original README section | New location | Content preserved? | Notes |
|---|---|---|---|
| `# Campus Canteen Pre-Order and Queue Management System` | README title | Yes | Retained as the document title. |
| Project description: COMP 018, Activity 3, pre-ordering, pickup/queue, stall and administrator capabilities, approved Activity 2 design, Spring Boot API, seven PostgreSQL tables | README introduction and `## What is in this repository` | Yes | Retained in the project overview; the Activity 3 project is distinguished from other groups' Activity 3 targets. |
| Project metadata table: Group, Members, Branch to test, Status | README metadata table | Yes | Existing members, `main`, and tracker status reference retained; unknown group number remains TBD. |
| Layer/Technology table | README technology table immediately after project metadata | Yes | PostgreSQL, Java/Spring, React/Vite, and API exercise options retained. |
| Repository inventory code block | `## What is in this repository` | Yes | Converted to a table; existing directories/files and their descriptions retained; new Activity 4–6 folders are added. |
| `## 1. Prerequisites` and prerequisites table | `## What You Need` and `## Prerequisites` | Yes | Existing tool versions and checks retained; new tester prerequisites are added. |
| JDK 21 guidance | `## What You Need`, `## Quick Setup`, and `## Prerequisites` | Yes | Warning not to change `java.version` to match another JDK is retained. |
| `## 2. Setup` | `## Quick Setup` and `## Setup` | Yes | Existing setup instructions are reordered and supplemented with observable expected results and failure actions. |
| `### Step 1: Clone` and clone commands | `## Quick Setup` and `## Setup` | Yes | Both commands retained with expected-result and troubleshooting notes. |
| `### Step 2: Create your settings file`, environment-variable descriptions, `.env` warning | `## Quick Setup`, `## Configuration reference`, and `## Security notes` | Yes | All four variable descriptions and never-commit warning retained; no actual local values are included. |
| `### Step 3: Create roles, database, tables and sample data` and PostgreSQL role commands | `## Quick Setup` and `## Setup` | Yes | Windows and Linux/macOS commands retained with expected results and failure actions. |
| Hidden superuser-password prompt warning | `## Quick Setup`, `## Troubleshooting`, and `## Setup` | Yes | Manual entry warning and authentication-failure message retained. |
| `db-access-control/07-security-restrictions.sql` cluster-wide `PUBLIC CONNECT` warning | `## Quick Setup`, `## Security notes`, and `## Setup` | Yes | Review all cluster databases first; cluster-wide impact is stated. |
| Seven-table `\dt` command and expected table list | `## Quick Setup`, `## Database`, and `## Setup` | Yes | Command and all seven table names retained. |
| `### Step 4: Start the API (port 8080)` JDK selection commands, Maven guidance, run commands, and endpoint expectation | `## Run the Application` and `## Setup` | Yes | Commands, JDK selection instructions, Maven download guidance, `Started CanteenApplication`, and expected three-stall endpoint behavior retained. |
| Wrong JDK folder/older JDK warning | `## Quick Setup`, `## Troubleshooting`, and `## Setup` | Yes | Existing failure mode and terminal-window guidance retained. |
| `### Step 5 (optional): Start the web client (port 5173)` and client commands | `## Run the Application` and `## Setup` | Yes | Node requirement, install-once note, browser URLs, fixed-port/CORS behavior, script-policy workaround, and frontend README link retained. |
| `## 3. Sample accounts` and sample account table | `## Sample accounts` | Yes | All sample emails, notes, and sample-only shared demo credential retained and clearly labeled as unsuitable for real credentials. |
| `## 4. Check that it works` | `## Run the Application`, `## Test Activity 4`, and `## Expected Results` | Yes | Existing app checks retained; COMP018 database-operations checks are added separately. |
| `### Automatic check` and smoke-test command/expected result | `## Run the Application`, `## Expected Results`, and `## Check that it works` | Yes | Command, operations performed, green `All steps ran.` expectation, and 23:59 Philippine-time constraint retained as expected behavior, not a claimed result. |
| `### Check in the web client` and web-client test table | `## Check that it works` and `## Expected Results` | Yes | All four existing role/action/expected-result rows retained. |
| `### Check by role` and API role-test table | `## Check that it works` and `## Expected Results` | Yes | Login/token instructions, endpoint link, all eight API action rows, and expected responses retained. The source's masked/incomplete authorization placeholder is clarified as standard `Authorization: Bearer <token>` syntax; no actual token is included. |
| `## 5. Application user roles` and role/database mapping table | `## Application user roles` | Yes | Student, Vendor, Administrator, runtime-account responsibilities and `canteen_app` membership mapping retained. |
| `## 6. Configuration reference` and configuration table | `## Configuration reference` | Yes | Every existing variable, meaning, default, and database-name note retained. |
| `## 7. Database`, seven table names, migration/access-control references | `## Database` | Yes | All seven tables, folder descriptions, and database documentation link retained. |
| `### Reset the data` and reset/seed commands | `## Database` and `## Reset the data` | Yes | Both commands retained with expected result and caution that table structures remain. |
| `## 8. Common problems` and troubleshooting table | `## Troubleshooting` and `## Common problems` | Yes | Every original problem/fix row retained; tester-specific rows supplement it. |
| Full troubleshooting documentation link | `## Troubleshooting` and `## Documentation index` | Yes | Link retained. |
| `## 9. Security notes` | `## Security notes` | Yes | Credential, BCrypt, JWT lifetime, allowed browser origins, and local/trusted-network notes retained. |
| `## 10. For groups testing this project` | `## For groups testing this project` and Activity 4–6 tester sections | Yes | Use own local PostgreSQL; do not edit this repository; record tested steps/roles; report deviations retained. |
| `## 11. Documentation index` | `## Documentation index` | Yes | All six original links retained, with Activity 4–6 references added. |
| `## 12. AI usage` | `## AI Usage` | Yes | Original Claude disclosure and PDF declaration requirement retained; known Copilot SDK use for this work and its validation are added without claiming unknown group-wide tool usage. |
| Original links to database, user-role, database-role, API, troubleshooting, and frontend documentation | Relevant README reference sections and `## Documentation index` | Yes | Link targets are retained and checked for existence. |
| New verifier scripts, `PASS`/`FAIL`/`SKIP`/`BLOCKED` semantics, and evidence locations | `## Test Activity 4`, `## Test Activity 5`, `## Test Activity 6`, `## Expected Results`, and `## Where Evidence Goes` | Yes | Added material; does not replace existing application setup or test instructions. |
| Existing warning: `.env` is ignored and must never be committed | `## Quick Setup` and `## Security notes` | Yes | Preserved verbatim in meaning. |
| Existing warning: a demo password exists only in sample data | `## Sample accounts` and `## Security notes` | Yes | Retained as sample-only and explicitly not a real credential. |
| Existing warning: API listens on all interfaces; use local/trusted network | `## Security notes` | Yes | Retained. |

No original section is intentionally replaced. The tester path is new material; existing setup, reference, application-test, and documentation content remains in the lower README sections.
