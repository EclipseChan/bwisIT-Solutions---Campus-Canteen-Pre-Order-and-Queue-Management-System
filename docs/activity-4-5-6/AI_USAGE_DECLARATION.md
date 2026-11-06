# AI Usage Declaration — Activities 4–6

**Status: DRAFT TEMPLATE — group review and approval are required before submission.** This declaration concerns scaffold/documentation assistance only; it is not database evidence or a claim that operational work passed.

## Tools used

- GitHub Copilot in VS Code (Copilot SDK) assisted with requirements mapping, safe verifier-script scaffolding, supporting documentation, template folder organization, and README/documentation checks in this repository.
- The original project README records Claude by Anthropic as having helped guide development. The group must confirm the dates/tasks and whether other tools were used.
- OpenCode, ChatGPT, and any additional tools: `<CONFIRM_WITH_ALL_GROUP_MEMBERS; LIST_ACTUAL_USE_OR_NONE>`.

## Tasks performed with AI assistance

- Organized the provided COMP018 Activity 4–6 requirements into traceability, tester, expected-results, evidence, and manual-check documents.
- Drafted reusable templates for access-control review, database health/log/maintenance/query-plan checks, and backup/archive/restore/recovery workflows.
- Drafted safe-use instructions, blockers, credential-rotation guidance, and README preservation material.
- Did not connect to another group's database, execute SQL maintenance, create or restore a database, fabricate evidence, or modify another group's repository or application business logic.

## Validation and human review

- Compared the scaffold against the supplied Phase 7–9 instructions; checked README headings/content-map coverage, internal links, and Markdown structure.
- Inspected generated PowerShell/SQL/Bash templates for placeholder status and secret handling. (Record any additional validation only after it has actually been run.)
- Phase 9 verifier dry-run: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify\run-all.ps1 -Project group-01 -DryRun` was run on 2026-11-05 using Windows PowerShell 5.1 because `pwsh` was unavailable. The process-scoped policy bypass did not change system policy. The transcript is [saved under Activity 4 evidence](../../evidence/activity-4/group-01/2026-11-05/run-all-20261105-001152.txt): 1 static backup-plan-section check reported `PASS`, 1 preview `SKIP`, and 21 checks `BLOCKED`; exit code was 1 due to blockers. No database or backup/restore/recovery operation ran. This does not establish operational compliance.
- A dry-run, generated suggestion, placeholder, or command completion alone is not evidence that a database operation passed. A human must review every project-specific script and real output against owner-approved requirements before use.

## Evidence and confidentiality statement

AI was not used to fabricate database, backup, restore, recovery, log, or tracker evidence. No real secret values were intentionally included in the generated files or shared with Copilot during this scaffold work. The group must confirm that statement covers all members and all tools actually used; do not disclose secrets to AI tools.

## Required completion

- [ ] Confirm every tool actually used, including Claude and any OpenCode/ChatGPT/Copilot use by each team member.
- [ ] Complete actual task/date details and reviewer names without adding secret values.
- [ ] Record validation only when performed and retain its real output.
- [ ] Obtain human review/approval and update the required PDF/tracker declaration.

Declaration owner: `<NAME>`

Review date: `<DATE>`

Human approval/status: `PENDING`
