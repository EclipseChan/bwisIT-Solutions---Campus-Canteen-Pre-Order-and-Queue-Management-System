-- Run by setup.ps1 / setup.sh as the PostgreSQL superuser.
-- Variables dbname, dbuser and dbpass are passed in with psql -v.
-- Both statements are skipped when the role or database already exists.
-- An existing role keeps its current password.

SELECT format('CREATE ROLE %I WITH LOGIN PASSWORD %L', :'dbuser', :'dbpass')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'dbuser') \gexec

SELECT format('CREATE DATABASE %I OWNER %I', :'dbname', :'dbuser')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'dbname') \gexec
