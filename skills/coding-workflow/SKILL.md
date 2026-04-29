---
name: coding-workflow
description: Structured 6-phase workflow (Questions → Plan → Implementation → Verification → Review → Commit/PR) for non-trivial coding tasks. Invoke automatically whenever the user's message starts with the literal prefix "Task:" (case-insensitive), and otherwise on explicit `/coding-workflow` request. Maintains a task note in ~/Documents/obsidian/Work/ai-tasks/ that advances through planning → implementing → verifying → reviewing → done.
---

# Coding workflow

Use this skill when the user gives you a coding task. Trigger automatically if
their message begins with `Task:`. Do not skip phases.

## Required sequence

1. Questions
2. Plan
3. Implementation
4. Verification
5. Review
6. Commit and PR

The `status:` field in the task note advances through:
planning → implementing → verifying → reviewing → done.
Advance it as you finish each step. Do not skip states.

## 1. Questions

Before planning or editing code:

- Inspect the relevant files first.
- Ask only blocking questions.
- If the task can proceed with reasonable assumptions, list those assumptions
  and continue.
- Do not ask questions just to delay progress.

## 2. Plan

Before implementation:

- Create or update a task note in `~/Documents/obsidian/Work/ai-tasks/`.
- If that directory does not exist, fall back to a private GitHub gist:
  - Create the gist on first write with
    `gh gist create --private --filename <YYYY-MM-DD-short-task-name>.md <file>`.
  - Capture the returned gist ID/URL and reuse it for the rest of the task —
    record it in the note's frontmatter as `gist:` so a restart can find it.
  - Subsequent updates use `gh gist edit <id> --filename <name>.md <file>`
    (write the note to a local temp file first, then push it with `gh gist edit`).
  - Do not create a new gist per update; always edit the existing one.
- Use this filename format:

  `YYYY-MM-DD-short-task-name.md`

- The note must include:
  - Task summary
  - Known context
  - Open questions
  - Assumptions
  - Implementation plan
  - Files likely to change
  - Verification plan
  - Risks

- Do not edit production code until the plan exists.
- For non-trivial changes, stop after writing the plan and ask me to approve it.
- Skip the task note entirely for trivial changes: under ~10 changed lines,
  no new logic (typo fixes, comment edits, dependency bumps). Proceed
  straight to implementation and verification.

### After plan approval, before Implementation

The plan note was written with my best guesses. The user's reply almost
always shifts something — record those shifts in the note **before** the
first code edit, otherwise the note silently drifts from reality:

- Write the user's answers directly into `## Questions` (next to the
  question, not in chat memory).
- Reconcile `## Assumptions` and `## Plan` with those answers — remove
  or rewrite items the user overrode. If a Plan step disappears, the
  remaining `- [ ]` list must still be a faithful execution sequence.
- Set `status: implementing`, fill in `branch:`, and update
  `**Resume from:**` to point at the first concrete step.
- Only after the note matches reality: create the branch and start
  editing code.

### Branch setup

Before implementation, check git state:

- "Clean" means: no staged changes, no unstaged modifications to tracked
  files. Untracked files are ignored — treat them as user's in-progress
  notes that have nothing to do with the task.
- If the repository is clean and the current branch is `main`, create a new
  branch. The branch name must not contain `/`. Do not include the Jira
  task ID (or any tracker ID) in the branch name — name it after what the
  change does, not what ticket it came from.
- If the repository has staged or unstaged modifications to tracked files,
  or the current branch is not `main`, stop and notify the user instead
  of proceeding.

## 3. Implementation

During implementation:

- Follow the approved plan.
- Keep changes focused.
- Prefer small, understandable edits.
- Keep code comments minimal. Default to none. Add a comment only when
  the WHY is non-obvious — a hidden constraint, a subtle invariant, a
  workaround for a specific bug, or behavior that would surprise a
  reader. Don't restate WHAT the code does (good names already do that),
  and don't reference the current task, fix, or callers ("added for X",
  "used by Y") — that belongs in the commit/PR, not the source.
- Update the task note with an implementation log:
  - What changed
  - Why it changed
  - Important decisions
  - Deviations from the original plan
- After each completed sub-step, mark the matching `- [ ]` item in `## Plan`
  as `- [x]` and update the `**Resume from:**` line at the top so a restart
  knows exactly where to continue.

## 4. Verification

After implementation:

- Run the relevant tests, type checks, linters, or build commands.
- If a command cannot be run, explain why.
- If no automated checks exist, describe the manual verification performed.
- Update the task note with:
  - Commands run
  - Results
  - Failures
  - Fixes applied

## 5. Review

After verification:

- Run the `/review` skill on the pending changes. Fall back to a manual
  `git diff` review if the skill is unavailable.
- Look for correctness, edge cases, security issues, maintainability, naming, and unnecessary complexity.
- Update the task note with:
  - Review findings
  - Remaining risks
  - Suggested follow-ups
  - Final status
- The `## Review` section must be non-empty before moving to step 6.
  If `/review` found nothing, write "No issues found" plus a one-line
  summary of what was reviewed (files / scope).

## 6. Commit and PR

After review:

- Stage and commit the changes. Write a commit message that explains the why,
  not just the what.
- Push the branch only if I ask. Open a PR only if I ask.
- PR body format: a simple bullet list of the main changes. No
  `## Summary` / `## Test plan` sections, no checklists, no footers.
- Update the task note: set `status:` to `done` and record the commit hash
  (and PR link if any) in `## Follow-ups`.
- Precondition for `status: done`: `## Implementation log`, `## Verification`,
  and `## Review` must each contain at least one substantive entry. If any
  is empty, stop and fill it before committing.

## Task note template

Use this structure for every task note:

---
type: ai-task
status: planning
created: YYYY-MM-DD
repo:
branch:
task:
---

# Task: <title>

**Resume from:** <one-line pointer to where to pick up after restart>

## Summary

## Context

## Questions

## Assumptions

## Plan

- [ ] step 1
- [ ] step 2

## Files likely to change

## Implementation log

## Verification

## Review

## Follow-ups
