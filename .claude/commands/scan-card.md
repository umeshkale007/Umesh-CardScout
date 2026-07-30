# /scan-card — Business Card Scanner and Researcher

You are executing a structured business card ingestion workflow for Umesh's Card-Scout tool.

The image path provided is: $ARGUMENTS

Follow every step in order. Do not skip any step. Do not proceed past a confirmation gate without explicit user approval. Do not fabricate any information at any step.

---

## STEP 1 — Image Validation and Preparation

Before reading the image, perform these checks and preparation steps in order:

1. The argument `$ARGUMENTS` is not empty. If it is empty, stop and say:
   "Please provide a file path. Usage: /scan-card inbox/your-card-photo.jpg"

2. The file exists at the path `$ARGUMENTS`. Check this using your file-reading capability.

3. The file extension is one of: `.jpg`, `.jpeg`, `.png`, `.webp`, `.heic`, `.heif`, `.bmp`, `.tiff` (case-insensitive).

4. The file path contains `inbox/` — this ensures images go through the designated staging folder.

If any check above fails, stop immediately and tell the user clearly what went wrong. Do not attempt to read an invalid file.

5. **Auto-compress if needed.** Run the image prep script to handle large files:

   ```
   python scripts/prep_image.py $ARGUMENTS
   ```

   - If the output starts with `ERROR:`, relay the error to the user and stop.
   - If the output is a file path, use that path for all subsequent steps (it may differ from `$ARGUMENTS` if compression was applied).
   - Store this as `READY_IMAGE_PATH` for use in Step 2.
   - If the path changed (i.e., a compressed copy was created), tell the user:
     "Image was large — a compressed copy was created for reading. Original is unchanged."

If any step fails, stop immediately and tell the user clearly what went wrong. Do not attempt to read an invalid file.

---

## STEP 2 — Vision Extraction

Read the business card image at `READY_IMAGE_PATH` (from Step 1) using your native vision capability.

Extract exactly these fields using only the text and graphics printed on the card. Do not use your training knowledge to supplement what you see:

| Field | Instructions |
|-------|-------------|
| `full_name` | Full name exactly as printed, including honorifics (Dr., Prof., etc.) if present |
| `job_title` | Exact job title as printed. If multiple titles, use the most senior one |
| `company` | Company or organization name exactly as printed |
| `phone` | All phone numbers, comma-separated. Include country code if printed |
| `email` | Email address exactly as printed, lowercase |
| `address` | Full mailing address as printed. Replace line breaks with commas |
| `website` | URL as printed. Remove trailing slash |

**If a field is not present on the card or is unreadable:** set it to `Not on card`

**Never guess a phone number, email address, or any other field.** If the print is unclear, say so in the field value (e.g., `Partially unreadable — appears to be +91 98...`).

After extraction, display the fields to the user in a clear formatted table.

---

## STEP 3 — User Confirmation Gate

Show the extracted fields in a table. Then ask:

```
Please review the extracted details above.

Reply with:
  YES — to proceed with research and save to Excel
  EDIT <field>: <new value> — to correct a field (e.g., EDIT email: john@company.com)
  CANCEL — to abort without saving anything
```

**If the user replies EDIT:**
- Apply the correction to your working copy of the data
- Show the updated table again
- Ask for confirmation again
- Repeat until the user replies YES or CANCEL

**If the user replies CANCEL:**
- Stop immediately
- Say: "Scan cancelled. Nothing has been written to contacts.xlsx."
- Do not proceed to any further steps

**If the user replies YES:**
- Proceed to Step 4

---

## STEP 4 — Web Research

Conduct real-time web research on the confirmed contact. You must perform a minimum of 6 searches and a maximum of 8 searches total. Use only the confirmed field values from Step 3 — do not supplement with values from your training data.

### Required Searches (run all 6):

**Search 1 — Person professional profile:**
Query: `"[full_name]" "[company]" professional`

**Search 2 — Person recent news:**
Query: `"[full_name]" "[company]" after:2023`

**Search 3 — Company recent news:**
Query: `"[company]" news after:2024`

**Search 4 — Company funding/announcements:**
Query: `"[company]" announcement OR funding OR acquisition 2024 OR 2025`

**Search 5 — Company challenges:**
Query: `"[company]" challenges OR "market headwinds" OR layoffs OR restructuring`

**Search 6 — Person LinkedIn/bio:**
Query: `"[full_name]" "[company]" site:linkedin.com OR bio OR profile`

### Optional Searches (choose 0–2 based on what would be most useful):

**Search 7 — Person speaking/publications:**
Query: `"[full_name]" conference OR speaker OR author OR publication`

**Search 8 — Company product/service detail:**
Query: `"[company]" "[job_title department keyword]" product OR service OR solution`

### Source Recording Rules:
- For every search, note the URLs you retrieve
- If a search returns no usable results for the query, note: `Search [N] returned no usable results`
- Never cite a URL that did not come from these searches
- Never construct or guess a URL

---

## STEP 5 — Research Synthesis

Synthesize your search findings into the sections below. Apply these rules to every section without exception:

**MANDATORY RULE:** Every specific claim (date, event, number, quote, person's role) must be followed by `Source: <URL>`. If you cannot source a claim, do not make it. Write `No verifiable info found` instead.

---

### Section A: Recent Company News (with dates + source URLs)

List up to 4 news items about the company from your searches. Format each item as:

```
[YYYY-MM-DD or "date not stated"] — <one-sentence summary> — Source: <URL>
```

If no relevant company news was found in searches: `No verifiable info found`

---

### Section B: Recent Personal/Career News (with dates + source URLs)

List up to 3 items about the person — role changes, awards, speaking engagements, publications, or media mentions. Format:

```
[YYYY-MM-DD or "date not stated"] — <one-sentence summary> — Source: <URL>
```

If no relevant personal news was found: `No verifiable info found`

**Important:** If the person's name is common and you cannot confirm the result refers to this specific individual, do not include it. Note the ambiguity in Section G instead.

---

### Section C: Key Company Announcements

List up to 3 formal company announcements — product launches, partnerships, major hires, expansions. Bullet points with source URLs:

```
• [YYYY-MM-DD or "date not stated"] — <announcement summary> — Source: <URL>
```

If none found: `No verifiable info found`

---

### Section D: Biggest Challenges/Concerns

List 2–4 challenges or pressures the company faces, based only on what sources explicitly report. This must be an actually reported concern — an earnings miss, a named lawsuit, a reported restructuring, a specific named competitive pressure from an article.

Format:
```
• [YYYY-MM-DD or "date not stated"] — <reported challenge> — Source: <URL>
```

Do NOT write:
- "Probably facing competitive pressure" (speculation)
- "Like many companies in this sector..." (generic)
- Any concern not traced to a specific URL from this session

If no sourced challenge was found: `No verifiable info found`

---

### Section E: Suggested Ice Breakers

Write 2–3 conversation starters for a business meeting. Each one MUST reference a specific, sourced fact from Section A, B, or C above. Append the source URL.

Format:
```
1. <ice breaker referencing a specific fact> (Source: <URL>)
```

Example of acceptable: "I saw that [Company] recently launched [specific product name] in [specific market] — curious how that's going so far. (Source: https://...)"

Example of NOT acceptable: "How's business going?" / "Great time to be in your industry!" / Any generic opener.

If research returned nothing specific enough to reference: `No specific facts found to support a sourced ice breaker. Recommend reviewing contacts.xlsx and searching manually.`

---

### Section F: Sources List

List all URLs you retrieved during Step 4, numbered sequentially. Include every URL — even those that yielded no useful content:

```
1. https://... — [brief note on what it contained or "no useful content found"]
2. https://...
...
```

---

### Section G: Research Caveats

Note any limitations that affect the reliability of the research above:

- **Name ambiguity:** If the person's name is common and results may refer to other individuals
- **Paywalled content:** If relevant articles were behind a paywall and could not be read
- **Conflicting sources:** If sources contradict each other (describe what conflicts)
- **Data age:** If the only results found are older than 12 months
- **Obscure subject:** If the company or person has minimal web presence

If no significant limitations: `No significant caveats identified`

---

## STEP 6 — Excel Write

Construct the following JSON from all confirmed and researched data. Then call `python scripts/excel_writer.py` and pass this JSON via stdin.

```json
{
  "date_scanned": "<today's date as YYYY-MM-DD>",
  "full_name": "<confirmed full_name from Step 3>",
  "job_title": "<confirmed job_title from Step 3>",
  "company": "<confirmed company from Step 3>",
  "phone": "<confirmed phone from Step 3>",
  "email": "<confirmed email from Step 3>",
  "address": "<confirmed address from Step 3>",
  "website": "<confirmed website from Step 3>",
  "card_image_file": "$ARGUMENTS",
  "research_status": "Complete",
  "recent_company_news": "<full text of Section A>",
  "recent_personal_news": "<full text of Section B>",
  "key_announcements": "<full text of Section C>",
  "biggest_challenges": "<full text of Section D>",
  "ice_breakers": "<full text of Section E>",
  "sources_list": "<full text of Section F>",
  "research_caveats": "<full text of Section G>"
}
```

Run the command and capture its output line.

If the script outputs a line beginning with `ERROR:`, stop immediately and relay the error message to the user in plain language. Do not attempt to write to contacts.xlsx any other way.

---

## STEP 7 — Completion Report

After the script exits successfully, tell the user:

```
Scan complete. Contact saved to contacts.xlsx.

  Name:            <full_name>
  Company:         <company>
  Row action:      <NEW CONTACT or UPDATED EXISTING ROW>
  Searches run:    <count>
  Sources cited:   <count of URLs in Section F>

Research confidence: <HIGH / MEDIUM / LOW — your honest assessment>
  HIGH = 4+ sourced facts found for this specific person/company
  MEDIUM = 1-3 sourced facts found, some sections show "No verifiable info found"
  LOW = Company or person has minimal web presence; most fields show "No verifiable info found"

If research confidence is LOW or MEDIUM, flag which sections are thin and suggest
the user manually verify or supplement the entry in contacts.xlsx.
```
