<div align="right" dir="rtl">

# SENIOR_MODE

> מטודולוגיית עבודה ל-Claude Code שהופכת אותו מכותב קוד מהיר לארכיטקט תוכנה סניור.
>
> **המהירות לא הייתה הבעיה. התהליך היה.**

[English version below](#english)

---

## הסיפור

הכל התחיל מפוסט ששותף איתי. הפוסט טען טענה פשוטה וחזקה: Claude Code לא סובל מחוסר ידע, הוא סובל מחוסר תהליך. הוא כותב קוד מהר יותר מרוב המפתחים, אבל אז מגיעות הבאגים — race condition, hard-coded string שהיה צריך להיות enum, transaction ש-rollback-ה audit record שהיה צריך להישמר, טסטים שבודקים `assert(true)` במקום את הערך הנכון.

כל תיקון מהיר. כל תיקון גורר אינסידנט, רגרסיה, retro. המהירות נטו, אחרי חישוב הבאגים, לא באמת גבוהה.

הפתרון הוא לא לשפר את הפלט, אלא לשנות את אופן החשיבה. מפתח ג'וניור קורא את הטיקט ומתחיל להקליד. מפתח סניור קורא את הטיקט, קורא את הקוד סביבו, קורא את הטסטים, בודק את ה-git log, ואז מקליד. איטי יותר — אבל לא חוזר לתקן את מה ששבר.

הפוסט הפנה ל-[`vlad-ko/claude-wizard`](https://github.com/vlad-ko/claude-wizard), skill מצוין שמיישם את ההגיון הזה ב-8 שלבים. קראנו אותו במלואו, אהבנו, ובמקום לשכפל — בנינו משהו מותאם.

**SENIOR_MODE הוא מנצח, לא תזמורת.** הוא לא ממציא גלגל. הוא לוקח את הרעיונות הטובים ביותר מ-`claude-wizard`, משלב אותם עם ה-skills הקיימים של [`superpowers`](https://github.com/obra/superpowers) ו-[`claude-combine`](https://github.com/obra/claude-combine), ומוסיף שלושה דברים שהרגשנו שחסרים.

---

## מה שמצאנו ש-/wizard לא פותר

1. **Over-process.** אם כל משימה עוברת את כל השלבים, תיקון טייפו נהיה טקס של 30 דקות. חייב סיווג.
2. **המודל לא יודע שהוא שוכח.** checklist ב-markdown הופך להמלצה בלבד כשאין אינדיקטור ויזואלי שמראה שבאמת מבצעים אותו.
3. **כל סשן מתחיל מאפס.** "אתמול החלטנו שאנחנו לא mock-ים את ה-DB כי נכווינו" נשכח אם אין memory gate.

## שלוש התוספות של SENIOR_MODE

### 1. Triage ב-3 רמות
לפני כל דבר, סיווג מהיר במילה אחת מהמשתמש:

| רמה | מתי | מה רץ |
|---|---|---|
| **TRIVIAL** | טייפו, log, rename, פחות מ-20 שורות | בלי תהליך. ישר לעבודה. |
| **STANDARD** | באג ב-1-3 קבצים, פיצ'ר ממוקד | Explore → Implement → Verify → Adversarial Review |
| **HEAVY** | concurrency, כסף, auth, schema, production, refactor רוחב | כל 7 השלבים כולל TDD ו-Memory Gate |

**הכלל הזהב להכרעה:** "אם זה ישבר ב-production, מה יקרה?" — לקוח מקבל חשבונית כפולה? Heavy. פיצ'ר אחד לא עובד? Standard. כלום מורגש? Trivial.

### 2. אינדיקטור ויזואלי חובה
כל תגובה של משימת קוד מתחילה ב-`## [SENIOR] Phase N`. אם אין header, המשתמש יודע שדילגו. ה-header הוא החלון היחיד של המשתמש אל מה שקורה בראש של Claude.

### 3. Memory Gate פרואקטיבי
בסוף כל משימת Heavy, Claude לא שואל "מה נזכור?" — הוא מציע רשומות זיכרון ספציפיות והמשתמש מסנן. זה ה"senior engineer doesn't start from zero every day".

---

## איך זה משתלב עם ה-skills הקיימים

SENIOR_MODE לא מחליף את ה-skills שיש לך. הוא מנצח עליהם:

| שלב ב-SENIOR_MODE | ה-skill שמופעל |
|---|---|
| Phase 0 — רעיון עמום | `superpowers:brainstorming` |
| Phase 1 — הבנה | `superpowers:writing-plans` |
| Phase 2 — חקירת הקוד | `Grep`, `Read`, `Explore` agent |
| Phase 3 — TDD | `claude-combine:test-driven-development` |
| Phase 4 — מימוש | `superpowers:executing-plans` |
| Phase 5 — אימות | `claude-combine:verification-before-completion` |
| Phase 6 — Adversarial Review | `claude-combine:requesting-code-review` |
| אחרי PR | `claude-combine:finishing-a-development-branch` |

---

## זרימה אמיתית

```
ההודעה שלך
   │
   ▼
[UserPromptSubmit hook]  ← רץ אוטומטית על כל הודעה
   │
   ├── שיחה / שאלה / מחקר? → תגובה רגילה, בלי header, דלג בשקט
   ├── יש "fast" / "בלי סניור"? → דלג בשקט
   ├── רעיון עמום? → הצע brainstorming קודם
   └── משימת קוד קונקרטית?
                    │
                    ▼
           ## [SENIOR] Triage
           סיווג מוצע: STANDARD
           סיבה: קובץ בודד, באג ממוקד, בלי state משותף
           אישור? (כן / heavy / trivial / דלג)
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

### 1. ה-skill
העתק את `skill/SKILL.md` לתיקיית ה-skills שלך:

```bash
mkdir -p ~/.claude/skills/senior-mode
cp skill/SKILL.md ~/.claude/skills/senior-mode/SKILL.md
```

### 2. ה-hook
העתק את ה-hook script:

```bash
mkdir -p ~/.claude/hooks
cp hooks/senior-mode-reminder.sh ~/.claude/hooks/senior-mode-reminder.sh
chmod +x ~/.claude/hooks/senior-mode-reminder.sh
```

### 3. רישום ה-hook ב-`~/.claude/settings.json`
הוסף את הבלוק הבא ל-`settings.json` הגלובלי שלך (צור את הקובץ אם הוא לא קיים):

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

אם כבר יש לך `hooks` ב-settings שלך, הוסף את הבלוק ל-`UserPromptSubmit` הקיים במקום להחליף את כל החלק.

**הערה למשתמשי Windows עם Git Bash:** החלף את הנתיב בקובץ settings בנתיב מוחלט כמו `bash C:/Users/<username>/.claude/hooks/senior-mode-reminder.sh`.

### 4. אתחול
אין צורך ב-restart. ה-hook מתחיל לירות על ההודעה הבאה שתשלח ל-Claude Code.

---

## יציאות חירום

לפעמים אתה רק רוצה לכתוב קוד בלי טקס. הוסף אחד מאלה להודעה שלך והמטודה תדלג בשקט:

- `fast`
- `בלי סניור`
- `בלי senior`

או תגיד `trivial` או `דלג` כשה-Triage מוצע.

---

## חולשות ידועות

אני מעדיף לציין את החולשות מאשר להסתיר אותן:

- **Triage תלוי בשיקול דעת של LLM.** הוא יכול לסווג לא נכון. ה-compromise הוא "LLM מציע, משתמש מאשר במילה אחת". זה עובד, אבל אם המשתמש מאשר בעיניים עצומות, הסיווג חוזר להיות אוטומטי.
- **ה-header הוא הבטחה, לא אכיפה.** שום דבר לא מונע מ-Claude לכתוב `## [SENIOR] Phase 2: Explore` בלי באמת להפעיל Grep. בפועל זה נראה שעצם חובת ה-header משפרת בצורה ניכרת, אבל זה לא מושלם.
- **Memory Gate יכול להתיישן.** אם אתה שומר הרבה רשומות זיכרון, חלקן יהפכו ל-stale. צריך לחזור אליהן מדי פעם.
- **עוד לא נבדק בתוך build pipelines או CI.** כרגע זה עובד ב-Claude Code interactive. הרחבה ל-CI היא עבודה עתידית.

---

## תודות וקרדיטים

הפרויקט הזה לא היה קיים בלי העבודה של מספר אנשים ופרויקטים:

### [Vlad Ko](https://github.com/vlad-ko) — מחבר [`claude-wizard`](https://github.com/vlad-ko/claude-wizard)
תודה ענקית ל-Vlad על ה-skill המקורי שהתחיל את כל הסיפור הזה. המבנה של 8 השלבים, שאלות ה-adversarial review, דגש על mutation testing mindset, והאנלוגיה של junior-mode מול senior-mode — כל אלה שלו. קראנו את ה-repo שלו במלואו לפני שנגענו בשורת קוד אחת, ו-SENIOR_MODE הוא במובן מסוים "claude-wizard מעובד לצרכים שלי". אם אתה מגיע לכאן מ-/wizard, קודם תסתכל על הריפו שלו — זה המקור.

### [Jesse Obra](https://github.com/obra) — מחבר [`superpowers`](https://github.com/obra/superpowers) ו-[`claude-combine`](https://github.com/obra/claude-combine)
המערכת של skills שבאמת נדלקים בזמן הנכון, ה-`brainstorming` skill שהופך רעיון עמום למפרט (שלא הייתי מוותר עליו בשום אופן), `writing-plans`, `executing-plans`, `test-driven-development`, `verification-before-completion` — כולם שם. SENIOR_MODE הוא פשוט conductor מעליהם. בלי התשתית הזו לא היה מה לנצח עליו.

### צוות Anthropic
על בניית Claude Code, מערכת ה-skills, ה-hooks, וה-memory system שמאפשרים לעבוד ככה מלכתחילה.

### המחבר של הפוסט
על השיחה שהתחילה את הכל. הפוסט לא שלי, אבל הוא הציף את הבעיה ואת הפתרון החלקי בצורה שגרמה לי לרצות לבנות את המשך הפתרון. תודה.

---

## רישיון

MIT — השתמש, שנה, הפץ. אם זה עזר לך, ספר ל-vlad-ko שזה נולד מהעבודה שלו.

---

## תרומה

PRs מבורכים. כיוונים שמעניינים אותי במיוחד:
- אכיפה אמיתית של ה-header (hook שבודק שהתגובה מתחילה ב-`## [SENIOR]`)
- אינטגרציה עם CI/CD pipelines
- קריטריוני Triage מדויקים יותר לשפות ספציפיות
- תרגומים ל-README לשפות נוספות

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
