-- Login credentials. The original design had none: vendors need an email and
-- password, and students carry a role so an administrator is a student with role ADMIN.
-- Same statements as add_auth_columns.sql in the repository root.

ALTER TABLE vendor  ADD COLUMN IF NOT EXISTS email VARCHAR(150) UNIQUE;
ALTER TABLE vendor  ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);
ALTER TABLE student ADD COLUMN IF NOT EXISTS role VARCHAR(20) NOT NULL DEFAULT 'STUDENT'
    CHECK (role IN ('STUDENT','ADMIN'));
