# AI Usage Declaration — Activities 5 and 6

**Status:** DRAFT TEMPLATE — verify and complete before submission. This records the AI assistance used to create the scaffold, not validation of database evidence or the final PDF.

## AI tools used

- Tool: GitHub Copilot in VS Code (Copilot SDK).
- Date/session: 2026-11-04; Copilot assistance in this VS Code session.
- Other AI tools: <NONE_OR_LIST_ACTUAL_TOOLS>.

## Tasks performed with AI assistance

- Interpreted the supplied COMP018 Activities 5/6 compliance context.
- Drafted reusable, clearly marked templates for database health, log review, maintenance, query-plan analysis, logical backup, archive inspection, restore verification, recovery simulation, reports, blockers, and submission checklists.
- Drafted repository hygiene, secret-scan, project-inventory, data-collection, and credential-rotation checklists.
- Did not connect to another group's database, execute SQL maintenance, create or restore a database, create a database dump, modify another group's repository, or alter application business logic.

## Validation performed

- Read the supplied compliance context and the repository's existing `.gitignore` and README before editing.
- Confirmed `.env` was ignored by Git and not tracked; did not open or disclose its contents.
- Inspected the pre-existing ZIP's entry names only; confirmed it contained `.env` and `frontend/node_modules/`.
- Verified Git ignore rules for `.env`/`.env.*`, `node_modules/`, `target/`, backup file patterns, and backup directories; confirmed `.env.example` remains available.
- Parsed the PowerShell backup templates and checked Bash syntax; tested that both backup scripts stop before `pg_dump` when required non-secret configuration is absent.
- Inspected the clean output ZIP's entry names only and confirmed no prohibited paths/extensions were included. This does not constitute a content secret scan.
- <RECORD_REVIEWER_AND_DATE_FOR_TEMPLATE_CONTENT_REVIEW>.
- No database output or operational result has been generated or represented as real evidence.

## Human review still required

- Confirm every project identity, account/role, database, version, reachability, and owner contact from authoritative sources.
- Review every SQL/script template against the target project's documented schema, privileges, and authorized environment before execution.
- Review all command output and reports against actual execution results; do not adopt AI-generated claims without verification.
- Review the final tracker, PDF, screenshots, and ZIP for secrets.
- Complete and verify the credential rotations listed in [CREDENTIAL_ROTATION_CHECKLIST.md](CREDENTIAL_ROTATION_CHECKLIST.md).

Declaration owner: <NAME>  
Review date: <DATE>  
Human approval/status: <PENDING>
