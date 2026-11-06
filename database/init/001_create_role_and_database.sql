-- Run as a PostgreSQL superuser after db-access-control/01-create-roles.sql.
-- psql variables dbname and dbuser are supplied by the setup scripts.
-- The administrator, not the application runtime, owns the database.

SELECT format('CREATE DATABASE %I OWNER %I', :'dbname', :'dbuser')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'dbname') \gexec

SELECT format('ALTER DATABASE %I OWNER TO %I', :'dbname', :'dbuser')
WHERE EXISTS (SELECT 1 FROM pg_database WHERE datname = :'dbname') \gexec
