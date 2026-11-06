-- Group role for the PHP application's database permissions.
CREATE ROLE parkit_runtime_grp WITH NOLOGIN;

-- Allow the application group to connect to the database
-- and use the public schema.
GRANT CONNECT ON DATABASE grp_parkitdb TO parkit_runtime_grp;
GRANT USAGE ON SCHEMA public TO parkit_runtime_grp;

-- Read the records needed by the application.
GRANT SELECT ON
    public.staff_user,
    public.vehicle,
    public."transaction",
    public.payment,
    public.parking_zone
TO parkit_runtime_grp;

-- Create vehicle and entry records, and record payments.
GRANT INSERT ON
    public.vehicle,
    public."transaction",
    public.payment
TO parkit_runtime_grp;

-- Update vehicle details, transaction status/exit information,
-- and the parking-zone active vehicle count.
GRANT UPDATE ON
    public.vehicle,
    public."transaction",
    public.parking_zone
TO parkit_runtime_grp;

-- Create a dedicated login account for the PHP application.
CREATE ROLE parkit_app WITH LOGIN PASSWORD 'ParkItApp2026!';

-- Give the application account the permissions of the group role.
GRANT parkit_runtime_grp TO parkit_app;
