#!/usr/bin/env bash
# UserPromptSubmit hook for senior-mode.
# Injects a lightweight reminder into every user prompt that tells Claude
# to apply the senior-mode triage protocol if the prompt is a code task.
#
# The actual logic (detection, classification, skipping) lives in
# ~/.claude/skills/senior-mode/SKILL.md — this hook only pokes Claude to
# remember it's there.

cat <<'EOF'
[senior-mode hook] Before responding, apply the senior-mode protocol from ~/.claude/skills/senior-mode/SKILL.md:

1. Is this a code task (feature/bug/refactor/implementation)? If NO → respond normally, no header, skip silently.
2. Does the message contain "fast" or "בלי סניור" or "בלי senior"? If YES → skip silently.
3. Is the idea fuzzy ("I have an idea...", "what if...", "I'm thinking about...")? If YES → propose brainstorming first.
4. Otherwise → propose a Triage classification (TRIVIAL / STANDARD / HEAVY) using the criteria in the skill, and wait for user confirmation before touching code.

Start code-task responses with a [SENIOR] header showing the current phase. Non-code responses: no header, no ceremony.
EOF
