# Activity 5/6 Blockers

**Current blocker:** Other groups' project inventory not yet available.

The `group-01`, `group-02`, and `group-03` directories are organizational placeholders only. They do not assert that these groups exist, are in scope, or are reachable. The canteen project owned by bwisIT Solutions is not an Activity 5/6 target.

## Other information not yet supplied

- Class tracker URL and confirmed project list.
- Project-specific repository URLs, database names, PostgreSQL versions, and Activity 4 account/application-role mappings.
- Project reachability and owner contacts.
- Instructor-approved setup or `CREATEDB` account for disposable restore databases.
- Permission to change PostgreSQL logging in a local test environment.
- Confirmation that the final tracker tabs and PDF have been updated.

## Security follow-up

The previous ZIP contained `.env` and `frontend/node_modules/`. It was shared outside the local environment. The four exposed values (`DB_PASSWORD`, `DB_ADMIN_PASSWORD`, `DB_READONLY_PASSWORD`, and `JWT_SECRET`) are reported as **pending rotation**. Rotate them through the authorized local/database procedures and verify the replacement before submission. No values are recorded here. See [CREDENTIAL_ROTATION_CHECKLIST.md](CREDENTIAL_ROTATION_CHECKLIST.md).

No project database has been inspected, no maintenance or backup command has been run, and no evidence is claimed by this scaffold.
