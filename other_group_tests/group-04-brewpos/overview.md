# Group 4 — BrewPOS test results

**Run date:** 2026-11-05  
**Source:** `brewpos-main.zip`  
**Environment:** Windows test machine; earlier disposable PostgreSQL 18.6 cluster on `127.0.0.1:55457`, plus the AI-created working copy's isolated cluster on `127.0.0.1:5433` and app on port 8081. The working copy matched the attached source across 85 non-runtime files.

| Activity | Status | Summary |
|---|---|---|
| [Activity 3](activity-3-report.md) | Passed with issues | Build and 19 tests passed earlier; the working copy was later started and all documented UI flows were verified. IDE debugger launch remains unverified. |
| [Activity 4](activity-4-report.md) | Passed with issues | Least-privilege app grants were verified; default cross-database CONNECT and missing future-object grants remain issues. |
| [Activity 5](activity-5-report.md) | Passed with issues | Health, sales, and query plan were verified on the working copy; active-instance maintenance was not rerun and production monitoring remains unverified. |
| [Activity 6](activity-6-report.md) | Passed with issues | A dump of the working copy restored with matching counts, sales, and app-role privileges; production recovery objectives and cluster-global role backup remain untested. |

No application source was changed. Browser flows were tested against the running working copy; a fresh Daily Sales screenshot was captured. The working copy's local database now includes the two test orders and manager-created menu data, and the app/database were left running.
