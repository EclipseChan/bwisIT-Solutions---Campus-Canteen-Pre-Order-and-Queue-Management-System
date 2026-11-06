-- TEMPLATE ONLY — replace the query with one real application SELECT.
-- No execution plan has been collected.
-- Project: <GROUP_NUMBER> - <PROJECT_NAME>
-- Database: <DATABASE_NAME>
-- Account / application role: <A4_ACCOUNT> / <APPLICATION_ROLE>
-- Query purpose: <PURPOSE>
-- Confirm this SELECT is safe in the approved test environment before using ANALYZE.

EXPLAIN
<REAL_APPLICATION_SELECT_QUERY>;

-- Use only for a safe SELECT in an approved test environment:
EXPLAIN (ANALYZE, BUFFERS)
<REAL_APPLICATION_SELECT_QUERY>;
