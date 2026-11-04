# Activities 4–6 Evidence Guide

**TEMPLATE — no evidence is implied by these instructions.** Save evidence only after an authorized real operation. Dry-run output must be labelled as a preview and must not be used to claim an operational check passed.

## Locations and file names

| Activity | Repository evidence location |
|---|---|
| 4 | `evidence/activity-4/<verified-project>/<yyyy-mm-dd>/` |
| 5 | `evidence/activity-5/<verified-project>/<yyyy-mm-dd>/` |
| 6 | `evidence/activity-6/<verified-project>/<yyyy-mm-dd>/` |

Use descriptive names such as `<check>_<yyyy-mm-dd>_<HHmmss>_<timezone>.txt`; do not include passwords, tokens, private data, or sensitive account names in filenames. Use the same verified project key consistently with the project inventory.

## Required record fields

For each command/action, record:

- Confirmed project/repository and database (non-secret identifiers only).
- Date/time and timezone.
- Account and database/application role used (never a password or credential).
- Exact command or action, excluding secret-bearing arguments.
- Actual result/status, exit code if available, warnings/errors, and relevant limitations.
- Evidence file/link and reviewer/owner feedback date where applicable.

Preserve raw command output only if it is safe to retain. If output contains secrets, sensitive personal information, or confidential SQL/literals, do not save or share the raw output; retain an appropriately redacted copy and identify that redaction occurred.

## Command output and screenshots

- Prefer plain-text output captured directly from the authorized command. Keep the original result distinct from any interpretation or summary.
- Screenshots are supplemental, not a substitute for complete text output. Capture only the relevant application/terminal area; exclude unrelated windows, tabs, user data, and notifications.
- Before saving or sharing any screenshot, inspect it at full resolution and redact credentials, tokens, connection strings, `.env` values, personal data, and sensitive query/log literals. Verify the redaction is opaque and cannot be reversed by selecting/copying text.
- Include a dry-run label when the output came from `-DryRun`; it is not operational evidence.
- Do not state `PASS` unless the real output supports the exact assertion and is saved.

## Redaction checklist

- [ ] No password, token, JWT, API key, connection string, or credential-bearing environment value.
- [ ] No `.env` contents, private key, or secret store output.
- [ ] No unnecessary personal/student information.
- [ ] No sensitive SQL parameters, log lines, or data rows.
- [ ] Redactions do not conceal whether a test actually succeeded or failed.
- [ ] Command, account/role, target database, time, status, and limitations remain understandable.

## Never commit or submit

- Data-bearing backup/dump/archive files, including `.dump`, `.backup`, `.pgdump`, `.sql.gz`, `.bak`, or compressed variants.
- `.env`, local config containing credentials, `.pgpass`, tokens, passwords, private keys, or connection strings.
- Unredacted logs, query output, screenshots, student/customer data, or credentials.
- Temporary backup/recovery working files or inaccessible raw evidence.

Keep data-bearing backup files in approved, access-controlled storage outside the repository and submission ZIP. Do not remove or overwrite original databases or initial backups.
