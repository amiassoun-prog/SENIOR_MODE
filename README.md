<div dir="rtl" align="right">

# SENIOR_MODE

> **מתודולוגיית עבודה ל-Claude Code שהופכת אותו מכותב קוד מהיר לארכיטקט תוכנה סניור.**
>
> המהירות מעולם לא הייתה הבעיה — התהליך הוא שהיה.

[For English, scroll down ↓](#english)

---

## הסיפור

הכל התחיל בפוסט ששותף איתי. הטענה בו הייתה פשוטה וחזקה: Claude Code אינו סובל מחוסר ידע, אלא מחוסר תהליך. הוא כותב קוד מהר יותר מרוב המפתחים, אך מיד אחריו מגיעים הבאגים — race conditions, מחרוזות קשיחות שהיו צריכות להיות enum, טרנזקציות שעושות rollback לרשומת audit שהייתה צריכה להישמר, וטסטים שבודקים `assert(true)` במקום את הערך האמיתי.

כל תיקון בודד מהיר. אבל כל תיקון גורר אינסידנט, רגרסיה ו-retro. המהירות נטו, אחרי חישוב הבאגים, אינה גבוהה באמת.

הפתרון אינו לשפר את הפלט אלא לשנות את אופן החשיבה. מפתח ג'וניור קורא את הטיקט ומתחיל להקליד. מפתח סניור קורא את הטיקט, קורא את הקוד סביבו, קורא את הטסטים, בודק את היסטוריית ה-git, ורק אז מקליד. איטי יותר — אך אינו חוזר לתקן את מה ששבר.

הפוסט הפנה אל [`vlad-ko/claude-wizard`](https://github.com/vlad-ko/claude-wizard), skill מצוין שמיישם את ההיגיון הזה בשמונה שלבים. קראנו אותו במלואו, התרשמנו, ובמקום לשכפל בחרנו לבנות משהו מותאם.

**SENIOR_MODE הוא מנצח, לא תזמורת.** הוא אינו ממציא את הגלגל מחדש. הוא לוקח את הרעיונות הטובים ביותר מ-[`claude-wizard`](https://github.com/vlad-ko/claude-wizard), משלב אותם עם ה-skills הקיימים של [`superpowers`](https://github.com/obra/superpowers) ו-[`claude-combine`](https://github.com/obra/claude-combine), ומוסיף שלושה דברים שהרגשנו שחסרו.

---

## מה ש-/wizard לא פותר

1. **עודף תהליך (over-process).** אם כל משימה עוברת את כל השלבים, תיקון של טייפו הופך לטקס בן שלושים דקות. נדרש סיווג חכם של המשימה לפני ההפעלה.
2. **המודל אינו יודע שהוא שוכח.** רשימת בדיקה ב-markdown הופכת להמלצה בלבד כשאין אינדיקטור חזותי שמוכיח שאכן מבצעים אותה.
3. **כל סשן מתחיל מאפס.** "אתמול החלטנו לא להשתמש ב-mocks על ה-DB כי נכווינו" יישכח בסשן הבא, אלא אם קיים שער זיכרון מובנה.

## שלוש התוספות של SENIOR_MODE

### 1. סיווג (Triage) בשלוש רמות
לפני כל דבר אחר, Claude מציע סיווג והמשתמש מאשר במילה אחת:

| רמה | מתי | מה רץ |
|---|---|---|
| **TRIVIAL** | תיקון טייפו, לוג, rename, פחות מעשרים שורות | בלי תהליך — ישר לעבודה |
| **STANDARD** | באג בקובץ אחד עד שלושה, פיצ'ר ממוקד | Explore ← Implement ← Verify ← Adversarial Review |
| **HEAVY** | מקביליות, כסף, הרשאות, schema, production, רפקטור רוחב | כל שבעת השלבים, כולל TDD ו-Memory Gate |

**הכלל הזהב להכרעה במקרי גבול:** שואלים *"מה יקרה אם זה ישבר ב-production?"*
לקוח יקבל חשבונית כפולה? → HEAVY. פיצ'ר אחד לא יעבוד? → STANDARD. דבר שאינו מורגש? → TRIVIAL.

### 2. אינדיקטור חזותי מחייב
כל תגובה על משימת קוד חייבת להתחיל בכותרת `## [SENIOR] Phase N`. בלעדיה, המשתמש יודע מיד שהתהליך דולג. הכותרת היא החלון היחיד של המשתמש אל מה שמתרחש בראשו של Claude — ולכן היא אינה ניתנת לוויתור.

### 3. שער זיכרון (Memory Gate) פרואקטיבי
בסיום כל משימת HEAVY, Claude אינו שואל "מה נזכור?". במקום זאת הוא מציע רשומות זיכרון קונקרטיות, והמשתמש רק מאשר או דוחה. זוהי השכבה של *"מפתח סניור אינו מתחיל כל יום מאפס"*.

---

## שילוב עם ה-skills הקיימים

SENIOR_MODE אינו מחליף את ה-skills שכבר יש לך — הוא מנצח עליהם:

| שלב ב-SENIOR_MODE | ה-skill שמופעל |
|---|---|
| Phase 0 — רעיון עמום (לפני המימוש) | `superpowers:brainstorming` |
| Phase 1 — הבנה ותכנון | `superpowers:writing-plans` |
| Phase 2 — חקירת בסיס הקוד | `Grep`, `Read`, סוכן `Explore` |
| Phase 3 — פיתוח מונחה-בדיקות (TDD) | `claude-combine:test-driven-development` |
| Phase 4 — מימוש | `superpowers:executing-plans` |
| Phase 5 — אימות עם פלט אמיתי | `claude-combine:verification-before-completion` |
| Phase 6 — ביקורת אדוורסרית | `claude-combine:requesting-code-review` |
| אחרי פתיחת PR | `claude-combine:finishing-a-development-branch` |

---

## זרימה אמיתית

תרשים הזרימה למטה מוצג באנגלית בכוונה, כדי לשמור על יישור תקין של תווי ציור הקופסה בתוך בלוק קוד RTL.

```
Your message
   │
   ▼
[UserPromptSubmit hook]  ← fires automatically on every message
   │
   ├── Conversation / question / research? → normal reply, no header, skip
   ├── Contains "fast" / "בלי סניור"? → skip silently
   ├── Fuzzy idea? → propose brainstorming first
   └── Concrete code task?
                    │
                    ▼
           ## [SENIOR] Triage
           Proposed: STANDARD
           Reason: single file, focused bug, no shared state
           Approve? (yes / heavy / trivial / skip)
                    │
          ┌─────────┼─────────┐
          ▼         ▼         ▼
       TRIVIAL   STANDARD    HEAVY
                             │
                             ▼
                  ## [SENIOR] Phase 1: Understand
                  ## [SENIOR] Phase 2: Explore
                  ## [SENIOR] Phase 3: TDD
                  ## [SENIOR] Phase 4: Implement
                  ## [SENIOR] Phase 5: Verify (real output!)
                  ## [SENIOR] Phase 6: Adversarial Review
                  ## [SENIOR] Phase 7: Memory Gate
```

---

## התקנה

### 1. התקנת ה-skill
יש להעתיק את `skill/SKILL.md` לתיקיית ה-skills הגלובלית של Claude Code:

```bash
mkdir -p ~/.claude/skills/senior-mode
cp skill/SKILL.md ~/.claude/skills/senior-mode/SKILL.md
```

### 2. התקנת ה-hook
יש להעתיק את סקריפט ה-hook ולהעניק לו הרשאות ריצה:

```bash
mkdir -p ~/.claude/hooks
cp hooks/senior-mode-reminder.sh ~/.claude/hooks/senior-mode-reminder.sh
chmod +x ~/.claude/hooks/senior-mode-reminder.sh
```

### 3. רישום ה-hook בקובץ `~/.claude/settings.json`
יש להוסיף את הבלוק הבא ל-`settings.json` הגלובלי (יש ליצור את הקובץ אם אינו קיים):

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/senior-mode-reminder.sh"
          }
        ]
      }
    ]
  }
}
```

אם יש לך כבר מפתח `hooks` בקובץ, מזגו את הבלוק אל מערך ה-`UserPromptSubmit` הקיים במקום להחליף את כל האזור.

**הערה למשתמשי Windows עם Git Bash:** יש להחליף את הנתיב בנתיב מוחלט, לדוגמה: `bash C:/Users/<username>/.claude/hooks/senior-mode-reminder.sh`.

### 4. הפעלה
לא נדרש restart. ה-hook יתחיל לפעול כבר בהודעה הבאה שתשלח ל-Claude Code.

---

## יציאות חירום

לעיתים פשוט רוצים לכתוב קוד בלי טקס. הוספה של אחת מהמילים הבאות להודעה תגרום למתודה לדלג בשקט:

- `fast`
- `בלי סניור`
- `בלי senior`

לחלופין, אפשר להשיב `trivial` או `דלג` בשלב הצעת ה-Triage.

---

## חולשות ידועות

עדיף לציין את החולשות מאשר להסתיר אותן:

- **הסיווג (Triage) תלוי בשיקול-דעת של LLM.** הוא עלול לסווג בטעות. הפשרה היא *"המודל מציע, המשתמש מאשר במילה אחת"*. זה עובד טוב בפועל, אך אם המשתמש מאשר בעיניים עצומות, הסיווג חוזר להיות אוטומטי דה-פקטו.
- **הכותרת היא הבטחה, לא אכיפה.** שום דבר אינו מונע מ-Claude לכתוב `## [SENIOR] Phase 2: Explore` מבלי להפעיל בפועל את `Grep`. בפועל ניכר שעצם חובת הכותרת משפרת משמעותית את ההתנהגות, אך זו אינה ערובה מוחלטת.
- **שער הזיכרון עלול להתיישן.** כאשר נשמרות רשומות זיכרון רבות, חלקן יהפכו למיושנות עם הזמן. מומלץ לבצע חזרה ובחינה תקופתית של רשומות הזיכרון.
- **טרם נבדק ב-CI או בצינורות build.** כרגע המתודה עובדת במצב אינטראקטיבי של Claude Code. הרחבה ל-CI נחשבת לעבודה עתידית.

---

## תודות וקרדיטים

הפרויקט הזה לא היה קם לתחייה ללא עבודתם של כמה אנשים ופרויקטים:

### [Vlad Ko](https://github.com/vlad-ko) — מחבר [`claude-wizard`](https://github.com/vlad-ko/claude-wizard)
תודה ענקית ל-Vlad על ה-skill המקורי שהתחיל את כל הסיפור הזה. מבנה שמונת השלבים, שאלות הביקורת האדוורסרית, הדגש על *mutation testing mindset* והאנלוגיה של מוד ג'וניור מול מוד סניור — כל אלה שלו. קראנו את ה-repo שלו במלואו לפני שנגענו בשורת קוד אחת, ו-SENIOR_MODE הוא במובן מסוים **"claude-wizard מעובד לצרכים שלנו"**. אם הגעת לכאן דרך `/wizard`, כדאי קודם לעיין בריפו שלו — זה המקור שהכל נולד ממנו.

### [Jesse Obra](https://github.com/obra) — מחבר [`superpowers`](https://github.com/obra/superpowers) ו-[`claude-combine`](https://github.com/obra/claude-combine)
מערכת ה-skills שבאמת נדלקת בזמן הנכון, ה-skill של `brainstorming` שהופך רעיון עמום למפרט מוגדר (ולא הייתי מוותר עליו בשום פנים ואופן), `writing-plans`, `executing-plans`, `test-driven-development`, `verification-before-completion` — כל אלה כבר קיימים בזכותו. SENIOR_MODE הוא פשוט מנצח מעל התזמורת שלו. בלי התשתית הזאת לא היה על מה לנצח.

### צוות Anthropic
על בניית Claude Code, מערכת ה-skills, מנגנון ה-hooks ומערכת הזיכרון — כל אלה מאפשרים לעבוד בצורה הזו מלכתחילה.

### מחבר הפוסט שהתחיל הכל
על השיחה שהניעה את הפרויקט. הפוסט אינו שלי, אך הוא הציף את הבעיה ואת הפתרון החלקי בצורה כה משכנעת, עד שרציתי לבנות את המשך הפתרון. תודה.

---

## רישיון

MIT — לשימוש חופשי, לשינוי ולהפצה. אם זה עזר לך, כדאי לספר ל-Vlad Ko שהפרויקט הזה נולד מתוך העבודה שלו.

---

## תרומה לפרויקט

בקשות משיכה (PRs) יתקבלו בברכה. הכיוונים שמעניינים אותי במיוחד:
- אכיפה אמיתית של הכותרת החזותית — hook משלים שיבדוק שהתגובה אכן מתחילה ב-`## [SENIOR]`
- אינטגרציה מלאה עם צינורות CI/CD
- קריטריוני Triage מדויקים יותר לשפות תכנות ספציפיות (Python, Java, Rust וכדומה)
- תרגומי README לשפות נוספות

</div>

---

<a id="english"></a>

# SENIOR_MODE (English)

> A working methodology for Claude Code that turns it from a fast coder into a senior software architect.
>
> **Speed was never the problem. Process was.**

## The Story

This started with a post someone shared with me. The post made a simple, powerful claim: Claude Code doesn't suffer from lack of knowledge — it suffers from lack of process. It writes code faster than most developers, and then come the bugs: race conditions, hard-coded strings that should have been enums, transactions that roll back the audit record that was supposed to persist, tests asserting `true` instead of the actual value.

Every fix is fast. Every fix drags an incident, a regression, a retro behind it. Net velocity, after counting the bugs, is not actually high.

The fix isn't improving the output — it's changing how the model thinks. A junior reads the ticket and starts typing. A senior reads the ticket, reads the surrounding code, reads the tests, checks git log, and *then* types. Slower — but doesn't come back to fix what broke.

The post pointed to [`vlad-ko/claude-wizard`](https://github.com/vlad-ko/claude-wizard), an excellent skill that implements this logic in 8 phases. I read the whole thing, loved it, and instead of cloning — built something tailored.

**SENIOR_MODE is a conductor, not an orchestra.** It doesn't reinvent wheels. It takes the best ideas from `claude-wizard`, combines them with the existing skills from [`superpowers`](https://github.com/obra/superpowers) and [`claude-combine`](https://github.com/obra/claude-combine), and adds three things I felt were missing.

## What I Found /wizard Doesn't Solve

1. **Over-process.** If every task runs every phase, fixing a typo becomes a 30-minute ceremony. We need classification.
2. **The model doesn't know it's forgetting.** A markdown checklist becomes a mere suggestion when there's no visual indicator proving it's actually being followed.
3. **Every session starts from zero.** "Yesterday we decided not to mock the DB because it burned us" is lost without a memory gate.

## SENIOR_MODE's Three Additions

### 1. Three-tier Triage
Before anything, a quick one-word classification from the user:

| Tier | When | What Runs |
|---|---|---|
| **TRIVIAL** | Typo, log, rename, <20 lines | No process. Straight to work. |
| **STANDARD** | Bug in 1-3 files, focused feature | Explore → Implement → Verify → Adversarial Review |
| **HEAVY** | Concurrency, money, auth, schema, production, wide refactor | All 7 phases including TDD and Memory Gate |

**Golden rule for edge cases:** "If this breaks in production, what happens?" — Customer gets double-billed? Heavy. One feature broken? Standard. Nothing noticeable? Trivial.

### 2. Mandatory Visual Indicator
Every code-task response starts with `## [SENIOR] Phase N`. Without the header, the user knows the methodology was skipped. The header is the user's only window into what's happening in Claude's head.

### 3. Proactive Memory Gate
At the end of each Heavy task, Claude doesn't ask "what should we remember?" — it *proposes* specific memory entries and the user filters. This is the "senior engineer doesn't start from zero every day" layer.

## Integration With Existing Skills

SENIOR_MODE doesn't replace your existing skills. It conducts them:

| SENIOR_MODE Phase | Invoked Skill |
|---|---|
| Phase 0 — fuzzy idea | `superpowers:brainstorming` |
| Phase 1 — understand | `superpowers:writing-plans` |
| Phase 2 — explore codebase | `Grep`, `Read`, `Explore` agent |
| Phase 3 — TDD | `claude-combine:test-driven-development` |
| Phase 4 — implement | `superpowers:executing-plans` |
| Phase 5 — verify | `claude-combine:verification-before-completion` |
| Phase 6 — adversarial review | `claude-combine:requesting-code-review` |
| Post-PR | `claude-combine:finishing-a-development-branch` |

## Real Flow

```
Your message
   │
   ▼
[UserPromptSubmit hook]  ← fires automatically on every message
   │
   ├── Conversation / question / research? → normal response, no header, skip silently
   ├── Contains "fast" / "בלי סניור"? → skip silently
   ├── Fuzzy idea? → propose brainstorming first
   └── Concrete code task?
                    │
                    ▼
           ## [SENIOR] Triage
           Proposed classification: STANDARD
           Reason: single file, focused bug, no shared state
           Approve? (yes / heavy / trivial / skip)
                    │
          ┌─────────┼─────────┐
          ▼         ▼         ▼
       TRIVIAL   STANDARD    HEAVY
                             │
                             ▼
                  ## [SENIOR] Phase 1: Understand
                  ## [SENIOR] Phase 2: Explore
                  ## [SENIOR] Phase 3: TDD
                  ## [SENIOR] Phase 4: Implement
                  ## [SENIOR] Phase 5: Verify (real output!)
                  ## [SENIOR] Phase 6: Adversarial Review
                  ## [SENIOR] Phase 7: Memory Gate
```

## Installation

### 1. The skill
Copy `skill/SKILL.md` to your skills directory:

```bash
mkdir -p ~/.claude/skills/senior-mode
cp skill/SKILL.md ~/.claude/skills/senior-mode/SKILL.md
```

### 2. The hook
Copy the hook script:

```bash
mkdir -p ~/.claude/hooks
cp hooks/senior-mode-reminder.sh ~/.claude/hooks/senior-mode-reminder.sh
chmod +x ~/.claude/hooks/senior-mode-reminder.sh
```

### 3. Register the hook in `~/.claude/settings.json`
Add this block to your global `settings.json` (create the file if it doesn't exist):

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/senior-mode-reminder.sh"
          }
        ]
      }
    ]
  }
}
```

If you already have `hooks` in your settings, merge this block into the existing `UserPromptSubmit` array instead of replacing the whole section.

**Windows + Git Bash note:** replace the path with an absolute one like `bash C:/Users/<username>/.claude/hooks/senior-mode-reminder.sh`.

### 4. Activation
No restart needed. The hook fires on the next message you send to Claude Code.

## Escape Hatches

Sometimes you just want to write code without ceremony. Add any of these to your message and the methodology will skip silently:

- `fast`
- `בלי סניור` (Hebrew: "without senior")
- `בלי senior`

Or say `trivial` or `skip` when the Triage is proposed.

## Known Weaknesses

I'd rather state the weaknesses than hide them:

- **Triage depends on LLM judgment.** It can misclassify. The compromise is "LLM proposes, user approves in one word". That works, but if the user rubber-stamps blindly, classification becomes de-facto automatic.
- **The header is a promise, not enforcement.** Nothing physically prevents Claude from writing `## [SENIOR] Phase 2: Explore` without actually running Grep. In practice the header obligation noticeably improves behavior, but it's not airtight.
- **Memory Gate can stale.** If you save many memory entries, some will become outdated. You need to revisit them occasionally.
- **Not yet tested inside CI pipelines.** Currently this works in interactive Claude Code. Extending to CI is future work.

## Credits & Acknowledgments

This project wouldn't exist without several people and projects:

### [Vlad Ko](https://github.com/vlad-ko) — author of [`claude-wizard`](https://github.com/vlad-ko/claude-wizard)
Enormous thanks to Vlad for the original skill that started all of this. The 8-phase structure, the adversarial review questions, the emphasis on mutation testing mindset, and the junior-vs-senior mode analogy — all his. I read the entire repo before writing a line of code, and SENIOR_MODE is in a real sense "claude-wizard adapted to my needs". If you arrive here from `/wizard`, look at his repo first — that's the source.

### [Jesse Obra](https://github.com/obra) — author of [`superpowers`](https://github.com/obra/superpowers) and [`claude-combine`](https://github.com/obra/claude-combine)
The skill system that actually fires when it should, the `brainstorming` skill that turns vague ideas into specs (which I would not give up under any circumstance), `writing-plans`, `executing-plans`, `test-driven-development`, `verification-before-completion` — they're all there. SENIOR_MODE is just a conductor over them. Without that foundation there'd be nothing to conduct.

### Anthropic team
For building Claude Code, the skills system, hooks, and memory system that make this kind of work possible in the first place.

### The author of the post
For the conversation that started everything. The post wasn't mine, but it surfaced the problem and the partial solution in a way that made me want to build out the rest of the solution. Thank you.

## License

MIT — use, modify, distribute. If this helped you, tell vlad-ko that it was born from his work.

## Contributing

PRs welcome. Directions I'm particularly interested in:
- Real enforcement of the header (a hook that checks responses start with `## [SENIOR]`)
- CI/CD pipeline integration
- More precise Triage criteria for specific languages
- Additional README translations
