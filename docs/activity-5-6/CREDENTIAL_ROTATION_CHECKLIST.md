# Credential Rotation Checklist

**Status:** TEMPLATE / INCOMPLETE — the previously shared ZIP contained `.env`. Rotation has not been completed or verified. Do not enter old or new credential values in this file, the repository, tracker, PDF, screenshots, or reports.

| Credential/configuration item | Rotation date (local record only) | Verification result (no values) | Status |
|---|---|---|---|
| `DB_PASSWORD` | <ROTATION_DATE_OR_PENDING> | <VERIFICATION_RESULT_OR_PENDING> | Pending |
| `DB_ADMIN_PASSWORD` | <ROTATION_DATE_OR_PENDING> | <VERIFICATION_RESULT_OR_PENDING> | Pending |
| `DB_READONLY_PASSWORD` | <ROTATION_DATE_OR_PENDING> | <VERIFICATION_RESULT_OR_PENDING> | Pending |
| `JWT_SECRET` | <ROTATION_DATE_OR_PENDING> | <VERIFICATION_RESULT_OR_PENDING> | Pending |

## Safe completion steps

- [ ] Coordinate rotation with the authorized database/application owner. Do not paste secrets into chat or repository files.
- [ ] Rotate each affected database credential and update only protected local configuration or approved secret storage.
- [ ] Replace the JWT signing secret in protected local configuration and invalidate/reissue affected sessions/tokens as appropriate for the application.
- [ ] Verify each replacement through an authorized, non-disclosing authentication/connectivity check. Record only date, pass/fail, and verifier.
- [ ] Confirm the old values are no longer accepted where the owner can safely test this.
- [ ] Do not claim completion until all four rows have a verified result.
- [ ] Rebuild and scan the final submission ZIP after rotation; keep credentials out of the archive.

**Do not store evidence containing credentials.** Record only a safe result such as `PASS — connection verified; no credential value recorded`.
