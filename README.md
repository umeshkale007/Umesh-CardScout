# Umesh's Card-Scout
### Turn a business card photo into a researched contact in Excel — one command

---

## What This Tool Does

You take a photo of a business card, drop it in a folder, and type one command. Card-Scout then:

1. **Reads the card** — extracts the name, title, company, phone, email, address, and website using AI vision (no typing required)
2. **Asks you to confirm** — shows you what it read and lets you correct anything before saving
3. **Researches the contact** — runs up to 8 web searches to find recent news, company announcements, and challenges
4. **Writes to Excel** — saves everything to `contacts.xlsx`, including source links for every claim
5. **Suggests ice breakers** — based only on real facts it actually found (never generic lines)

---

## What This Costs

Card-Scout runs inside **Claude Code**, which requires either:

- **Claude Pro or Max subscription** (claude.ai) — a flat monthly fee; Claude Code usage is included
- **Pay-as-you-go Anthropic API key** — you pay per message; costs scale with how many cards you scan

**Neither option is free.** A typical card scan (vision + 6–8 web searches + research synthesis) uses roughly 5,000–15,000 tokens. On a Pro plan this is included in your subscription. On pay-as-you-go, this is a fraction of a cent per scan, but costs add up if you scan hundreds of cards.

**Warning:** Do not use someone else's API key. API keys are personal credentials tied to a billing account. Using another person's key without permission may violate Anthropic's terms of service and expose them to unexpected charges.

---

## One-Time Setup

### Step 1 — Install Python 3

Card-Scout needs Python 3 to save data to Excel.

**On Mac:**
1. Open **Terminal** (press `Command + Space`, type `Terminal`, press Enter)
2. Type: `python3 --version` and press Enter
3. If you see something like `Python 3.11.4`, Python is already installed. Skip to Step 2.
4. If you get an error, go to [python.org/downloads](https://python.org/downloads), download the latest version, and run the installer. When asked, check the box that says "Add Python to PATH".

**On Windows:**
1. Press the **Windows key**, type `cmd`, and press Enter to open Command Prompt
2. Type: `python --version` and press Enter
3. If you see `Python 3.x.x`, Python is already installed. Skip to Step 2.
4. If not, go to [python.org/downloads](https://python.org/downloads), download and run the installer. **Important:** On the first installer screen, check "Add Python to PATH" before clicking Install.

---

### Step 2 — Install the openpyxl Library

This is a small library that lets Python read and write Excel files.

**On Mac (in Terminal):**
```
pip3 install openpyxl Pillow
```

**On Windows (in Command Prompt):**
```
py -m pip install openpyxl Pillow
```

You should see messages ending in `Successfully installed openpyxl Pillow`. If it says "already installed", that's fine too.

`openpyxl` handles the Excel file. `Pillow` automatically compresses large card photos before reading — without it, very large images will fail.

---

### Step 3 — Install Claude Code

Claude Code is the tool that runs Card-Scout. You install it from Anthropic's website — no technical knowledge needed.

**On Mac:**
1. Go to [claude.ai/code](https://claude.ai/code)
2. Download the Mac installer (.dmg file)
3. Open the downloaded file and drag Claude Code to your Applications folder
4. Open Claude Code from your Applications folder

**On Windows:**
1. Go to [claude.ai/code](https://claude.ai/code)
2. Download the Windows installer (.exe file)
3. Run the installer and follow the prompts
4. Open Claude Code from your Start menu

---

### Step 4 — Log In to Claude Code

When you open Claude Code for the first time, it will ask you to log in.

**Option A — Claude subscription (Pro or Max):**
1. Click "Sign in with Anthropic"
2. Log in with your claude.ai email and password
3. Done — your subscription covers usage

**Option B — API key:**
1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Click "API Keys" and create a new key
3. Copy the key (it starts with `sk-ant-...`)
4. In Claude Code, paste the key when prompted
5. Add a payment method in the Anthropic console so charges can be billed

---

### Step 5 — Open This Folder in Claude Code

1. Open Claude Code
2. Click **File → Open Folder** (Mac) or **File → Open** (Windows)
3. Navigate to the `card-scout` folder and select it
4. You should see the folder's files on the left side of the screen

---

## How to Scan a Card

### Every time you want to scan a card:

**Step 1 — Take or get the photo**
- Take a clear, well-lit photo of the card
- Acceptable formats: JPG, JPEG, PNG
- Try to keep the card flat and the text readable

**Step 2 — Drop the photo into the `inbox` folder**
- Copy or move the photo file into the `card-scout/inbox/` folder
- Give it a recognizable filename like `john_smith_acme.jpg`

**Step 3 — Open the terminal inside Claude Code**
- In Claude Code, look for a "Terminal" tab at the bottom of the screen
- Click it to open the terminal
- Make sure you are in the `card-scout` folder (you should see `card-scout` in the terminal prompt)

**Step 4 — Run the scan command**
```
/scan-card inbox/john_smith_acme.jpg
```

Replace `john_smith_acme.jpg` with the actual filename of your photo.

**Step 5 — Confirm the extracted details**
- Claude Code will show you the name, title, company, and other fields it read from the card
- If everything looks correct, type `YES` and press Enter
- If something is wrong, type `EDIT` followed by the field name and the correct value:
  ```
  EDIT email: john.smith@acmecorp.com
  ```
- Type `CANCEL` if you want to stop without saving anything

**Step 6 — Wait for research to complete**
- This usually takes 1–3 minutes
- Claude Code is running web searches and writing the results
- You will see a completion message when it is done

**Step 7 — Open contacts.xlsx**
- The file `contacts.xlsx` is in the `card-scout` folder
- Open it in Excel or Google Sheets to see the new entry

---

## What to Do When a Field Shows "No verifiable info found"

This is expected behavior, not a bug.

It means web searches did not turn up a verifiable source for that piece of information. This happens when:
- The person or company has limited public web presence
- The information exists only behind paywalls
- The name is common and results could refer to different people
- The company is new or regional and not widely covered

**What you can do:**
- Check LinkedIn manually for the person's profile
- Visit the company's website directly
- Ask the contact directly when you meet them
- Leave the field as-is — "No verifiable info found" is honest and accurate

**What Card-Scout will never do** is invent information to fill these gaps. If it cannot source a fact, it says so.

---

## What to Do If Something Goes Wrong

**"File not found"**
The file path you typed does not match the actual file. Check that the photo is inside the `inbox` folder and that you spelled the filename correctly (including the extension like `.jpg`).

**"Excel file is open — close contacts.xlsx and run again"**
You have contacts.xlsx open in Excel at the same time as the scan. Close the Excel file, then run the scan command again.

**"openpyxl is not installed"**
Run `pip3 install openpyxl` (Mac) or `py -m pip install openpyxl` (Windows) in the terminal, then try again.

**"No response" or Claude seems stuck**
Check your internet connection. Web research requires an active connection. If the issue persists, close Claude Code and reopen it.

**Research confidence shows LOW**
The contact or company has minimal web presence. This is common for local businesses, small firms, or people who avoid social media. The data in Excel is still accurate — it just means less was found. Use the Sources List column to see exactly what was checked.

---

## Privacy Note

- Business card photos stay in the `inbox` folder on your computer
- Card data is sent to Anthropic's API for processing (same as any Claude conversation)
- Web search queries contain the person's name and company — this is sent to a search service
- `contacts.xlsx` is stored locally on your machine
- It is recommended **not** to sync the `inbox` or `contacts.xlsx` to a shared cloud drive, especially if you work with confidential contacts

---

## Frequently Asked Questions

**Can I scan multiple cards at once?**
Not in the current version. Run `/scan-card` once per card.

**What if I scan the same card again?**
The tool will update the existing row in contacts.xlsx rather than create a duplicate. Your research data will be refreshed.

**Can I edit contacts.xlsx manually?**
Yes. The Excel file is a plain .xlsx file — you can open it in Excel or Google Sheets and edit, sort, filter, or add columns as you wish. Card-Scout will not overwrite your manual changes unless you rescan the same card.

**What image quality do I need?**
Good lighting and a flat, in-focus photo. Glare, extreme shadows, or very small text can cause extraction errors — which is why the confirmation step exists.

**What languages are supported?**
The AI vision can read cards in most Latin-script languages. Cards in other scripts (Chinese, Arabic, Devanagari, etc.) may work but extraction accuracy will vary.
