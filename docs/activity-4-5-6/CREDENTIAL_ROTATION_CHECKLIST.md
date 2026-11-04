# Credential Rotation Checklist

**Status: PENDING — no credential values belong in this file.** The previously shared archive is reported to have included `.env`; authorized owners must assess exposure and complete rotation before final distribution.

| Credential/configuration item | Rotation date (record date only) | Old credential fails | New credential works | Local `.env` updated, not committed | Status |
|---|---|---|---|---|---|
| `DB_PASSWORD` | `<PENDING>` | `<PENDING — no value>` | `<PENDING — no value>` | `<PENDING>` | Pending |
| `DB_ADMIN_PASSWORD` | `<PENDING>` | `<PENDING — no value>` | `<PENDING — no value>` | `<PENDING>` | Pending |
| `DB_READONLY_PASSWORD` | `<PENDING>` | `<PENDING — no value>` | `<PENDING — no value>` | `<PENDING>` | Pending |
| `JWT_SECRET` | `<PENDING>` | `<PENDING — no value>` | `<PENDING — no value>` | `<PENDING>` | Pending |

## Safe completion steps

- [ ] Contact the authorized database/application owner and coordinate a rotation window. Do not paste old or new values into chat, Git, this checklist, a tracker, PDF, screenshot, or evidence.
- [ ] Rotate each affected database credential and replace it only in protected local `.env` or approved secret storage. Confirm `.env` remains ignored and untracked; never copy it to a submission directory.
- [ ] Replace the JWT signing secret in protected local configuration and invalidate/reissue affected sessions/tokens as the owner requires.
- [ ] Verify the old credential fails and the new credential works using an authorized, non-disclosing check. Record only the date, verifier, and pass/fail.
- [ ] Rebuild the clean submission ZIP after rotation; inspect entry names and scan contents without exposing secret values. Confirm `.env`, dumps, backups, and `node_modules` are absent.
- [ ] Remove the previously shared ZIP where authorized, or restrict access and securely retain it according to the owner's policy. Record the disposition without including a link that grants access.
- [ ] Confirm no credential values appear in Git, ZIP, PDF, tracker, screenshots, scripts, logs, or AI usage records.

Do not mark rotation complete until all four rows and the archive-disposition steps are verified. See [Evidence Guide](EVIDENCE_GUIDE.md); it is unsafe to save evidence containing any credential.
