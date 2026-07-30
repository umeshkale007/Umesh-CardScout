# Card-Scout Project — Claude Behavioral Instructions

These instructions govern all Claude behavior in this project.
They override default Claude Code behavior where they conflict.

---

## Tool Scope

This project uses one slash command: `/scan-card`

You may also be asked to fix bugs in `scripts/excel_writer.py`.
Do not perform any other file operations or network requests outside of a `/scan-card` session.

---

## Truthfulness Rules (Non-Negotiable)

1. Every factual claim about a person or company MUST cite a URL retrieved during the current scan session's web searches. No exceptions.

2. If no verifiable source exists for a claim, write exactly:
   `No verifiable info found`
   Do not write "likely", "probably", "may have", "it is reasonable to assume", or any similar hedge as a substitute for a sourced fact.

3. Do not use your training data to fill in contact details, company facts, or news items. Your training data may be stale or wrong for specific individuals and companies. Use web search results from the current session only.

4. Do not fabricate URLs. If a URL is cited, it must have been retrieved in Step 4 of the current scan session. Do not construct plausible-looking URLs from memory.

5. If the person's name is common and search results are ambiguous, note this explicitly in Research Caveats:
   `Name ambiguity: multiple individuals match this name. Results may not correspond to this specific person.`

---

## Search Budget

- **Minimum:** 6 web searches per `/scan-card` session
- **Maximum:** 8 web searches per `/scan-card` session

Do not run additional searches beyond the 8-search cap even if the user asks for more. If asked, explain the cap. Do not run fewer than 6 even if early results seem sufficient.

---

## Source Citation Format

All citations in the Excel output must use this exact format:
```
[YYYY-MM-DD or "date not stated"] — <summary> — Source: <URL>
```

Example:
```
[2024-11-15] — Acme Corp raised $40M Series B — Source: https://techcrunch.com/2024/11/15/acme-series-b/
```

If the source page does not state a publication date, write `date not stated`. Do not guess or infer dates from surrounding context.

---

## Ice Breaker Rules

Ice breakers MUST:
- Reference a specific, sourced fact from the web research in this session
- Be professional and relevant to a business context
- Append the source URL in parentheses: `(Source: <URL>)`

Ice breakers MUST NOT:
- Be generic (e.g., "I noticed you work in tech", "It's a great time to be in your industry")
- Reference personal information not relevant to a professional context (family, personal social media, non-public location data)
- Be based on training data rather than search results retrieved in this session

---

## "Biggest Challenges/Concerns" Rules

This section must reflect **actually reported** concerns — an earnings miss, a named lawsuit, a reported restructuring, a specific competitive threat named in an article. Write:
```
[2024-09-03] — <company> reported a 12% revenue decline in Q2 2024 — Source: <URL>
```

Do NOT write:
- "Probably facing competitive pressure" (speculation)
- "Like many companies, they may be dealing with macro headwinds" (generic)
- Any concern not traceable to a specific URL retrieved in this session

If no sourced challenge is found, write exactly: `No verifiable info found`

---

## Excel Write Rules

- Always invoke `python scripts/excel_writer.py` for Excel operations — pass the JSON payload via stdin
- Never attempt to modify `contacts.xlsx` directly using inline Python in the session
- The script handles deduplication — do not implement deduplication logic in the slash command
- Relay the script's exit line to the user verbatim

---

## Data Handling

- Business card images stay in `inbox/` — do not copy them elsewhere
- Do not include image content or base64 data in the JSON sent to `excel_writer.py` — only the file path string
- Do not display raw image binary content in terminal output

---

## Abort Conditions

Stop the scan immediately and do not write to Excel if:
- The user replies CANCEL at the confirmation gate
- The image file does not exist at the given path
- `excel_writer.py` exits with an `ERROR:` line

Tell the user what happened in plain language. Never silently continue after an abort condition.

---

## Python Environment

Python 3 is required. The only third-party library used is `openpyxl`.
If `import openpyxl` fails, tell the user:
`Run: pip install openpyxl` (Mac/Linux) or `py -m pip install openpyxl` (Windows)

Do not use Node.js, JavaScript, or any runtime other than Python 3.
