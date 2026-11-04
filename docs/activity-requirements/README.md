# Activity Requirement Text Extracts

These files are **plain-text extracts** of the official COMP018 activity PDFs. They exist so
that AI tools (GitHub Copilot, Claude, ChatGPT, OpenCode) and simple text search can read the
requirements without struggling with PDF parsing.

| File | Source |
|---|---|
| `COMP018_Activity_4_Requirements.md` | `COMP018_Activity_4.docx.pdf` |
| `COMP018_Activity_5_Requirements.md` | `COMP018_Activity_5.docx.pdf` |
| `COMP018_Activity_6_Requirements.md` | `COMP018_Activity_6.docx.pdf` |
| `ALL_ACTIVITY_REQUIREMENTS.md` | All three, combined |

## Important

- **The PDFs remain the authoritative source.** These extracts are for context and search.
- Formatting is simplified. Tables, bullets, and page layout may not match the PDF.
- Each file is organised as `## Page N` followed by the extracted text of that page.
- Lines are wrapped at about 110 characters so tools and editors do not truncate long lines.
- If an extract looks truncated or garbled, open the PDF for that page.
- Do not edit these files to change a requirement. Edit the source PDF instead and re-extract.

## Regenerating

From the folder that contains `extract_requirements.py`:

```powershell
python .\extract_requirements.py
```

The script reads the three PDFs from `C:\Users\Marcos\Downloads\` by default. Update the
paths inside `extract_requirements.py` if the PDFs move.

## Using these files with Copilot

1. Put this folder inside the repository, for example `docs/activity-requirements/`.
2. In Copilot Chat, reference a file explicitly with `#file` or `#codebase`.
3. Attach the `.md` files, not the `.pdf` files.
4. Work one activity at a time.
5. If Copilot still stalls, paste the relevant `## Page N` text directly into the chat.

See `COMP018_Copilot_Evidence_Prompt.md` for the full prompt and workaround notes.
