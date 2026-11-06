# Secret and Submission Artifact Scan Checklist

**Status:** TEMPLATE — complete each scan immediately before submission. Do not copy secret values or raw scanner findings into reports. If a scanner detects a candidate, restrict access to the output, validate it locally, rotate if exposed, and record only the file/path and remediation status.

## Repository

- [ ] Confirm `.env` and other local secret files are not tracked or staged; keep `.env.example` only if it contains placeholders.
- [ ] Confirm `.gitignore` excludes `*.dump`, `*.backup`, `*.sql.gz`, `backups/`, `node_modules/`, and `target/`.
- [ ] Run an approved secret scanner over tracked source and documentation, excluding dependency/build directories and local `.env` files.
- [ ] Review scanner matches locally without pasting values into an issue, tracker, commit, chat, or this checklist.
- [ ] Check `git status` and staged changes for `.env`, backup data, screenshots, and generated local configuration.

## Submission ZIP

- [ ] Inspect archive **entry names only** and confirm no `.env`, `node_modules/`, `target/`, dumps, backup files, or `backups/` directory is present.
- [ ] Scan archive text entries using an approved secret scanner; do not extract or display `.env` content.
- [ ] Confirm the ZIP was built from the intended repository and is at the declared final path.

Suggested Windows PowerShell name-only check:

```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead("<FINAL_ZIP_PATH>")
try {
  $zip.Entries |
    Where-Object {
      (($_.FullName -match '(^|/)\.env(\.[^/]+)?$') -and ($_.FullName -notmatch '(^|/)\.env\.example$')) -or
      ($_.FullName -match '(^|/)(node_modules|target|backup|backups|dump|dumps)/') -or
      ($_.FullName -match '(?i)\.(dump|backup|bak|pgdump)$') -or
      ($_.FullName -match '(?i)\.(sql|dump|backup)\.gz$')
    } |
    Select-Object FullName, Length
} finally {
  $zip.Dispose()
}
```

An empty result is required. This checks names, not file contents.

## PDF

- [ ] Search/review every page, including images and terminal screenshots, for passwords, tokens, connection strings, `.env` contents, private keys, and unredacted scanner output.
- [ ] Confirm no project-owner or infrastructure details are included unless approved for submission.
- [ ] Record the PDF filename, review date, reviewer, and pass/block result without reproducing sensitive text.

## Tracker

- [ ] Review every Activity 5/6 row, comment, link, and attachment for passwords, tokens, credential-bearing connection strings, and private infrastructure details.
- [ ] Keep account names only where the rubric requires them; never enter account passwords.
- [ ] Confirm links point to approved evidence and contain no embedded credentials.

## Screenshots and terminal captures

- [ ] Review the entire image/frame, including terminal history, title bars, path bars, notifications, and background windows.
- [ ] Redact secrets before insertion; verify the redaction is opaque and cannot be removed or selected as hidden text.
- [ ] Prefer text output with sensitive values removed over screenshots.

## Scan record

- Repository artifact/exclusion check: 2026-11-04 / Git `check-ignore` and `ls-files` / PASS for configured exclusions; no tracked `.env` or backup artifacts. A complete content secret scan is still pending.
- ZIP entry-name check: 2026-11-04 / PowerShell `.NET ZipArchive` / PASS for the clean output archive after its final rebuild; prohibited entry count must remain zero. This is not a content secret scan.
- Generated scaffold text pattern check: 2026-11-04 / `rg` high-confidence key, private-key, JWT, and credential-URI patterns / 0 matches. This limited check does not replace a full approved repository scan.
- Repository content secret scan: <PENDING — approved full scanner and human review still required>
- ZIP content secret scan: <DATE / TOOL / PASS_OR_BLOCKED / FINDING_COUNT_ONLY>
- PDF review: <DATE / REVIEWER / PASS_OR_BLOCKED>
- Tracker review: <DATE / REVIEWER / PASS_OR_BLOCKED>
- Screenshot review: <DATE / REVIEWER / PASS_OR_BLOCKED>
- Follow-up/remediation (no values): <STATUS>
