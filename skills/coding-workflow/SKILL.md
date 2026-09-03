---
name: coding-workflow
description: Structured 3-phase workflow (Questions → Plan → Implementation). Invoke only on explicit `/coding-workflow` request. Maintains a task note in ~/src/ai-tasks/.
---

# Coding workflow

This skill runs only when the user explicitly invokes `/coding-workflow`. Do not skip phases.

## Required sequence

1. Questions
2. Plan
3. Implementation

## 1. Questions

Before planning or editing code:

- Inspect the relevant files first.
- Never resolve an open point by inventing the answer. The test for every
  open point is provenance: can the answer be derived from available data —
  the request itself, the codebase and its conventions, tests, docs? If
  yes, derive it and verify it in the files; it is neither a question nor
  an assumption.
- If the answer is not derivable, it exists only in the user's head —
  intent, scope, priorities, tolerance for behavior changes, external
  constraints. It must reach the user; the only choice is the channel:
  - the answer shapes the plan (architecture, scope, code outside the
    task, or hard to change later) — ask before writing the plan;
  - any reasonable default works and is easy to change later — the
    point becomes an `## Assumptions` entry, written with its basis
    when the note is created; the user reviews these at plan approval.
    An assumption whose basis you cannot state is a question.
- Get the asked questions answered before writing the plan: a
  plan-shaping point is settled by the user's answer, never by a
  guess; a guess is legitimate only as an `## Assumptions` entry on
  a point where any reasonable default works.
- No architectural decisions of your own, no additional tasks beyond
  the request, no "fixes" to parts the task does not touch.

## 2. Plan

Before implementation:

- Create a task note in `~/src/ai-tasks/`.
- Use this filename format:

  `YYYY-MM-DD-short-task-name.md`

- In the frontmatter, fill `task:` with a short description of what we
  are doing, optionally followed by the issue id from the tracking
  system, and `repo:` with the repository the task is in (owner/name,
  as in the git remote). `branch:` is filled later, at branch setup.
- `status:` moves through exactly these values: `planning` at note
  creation, `in-progress` at branch setup, `done` or `superseded` at
  close.
- The note has exactly five sections — Summary, Context, Assumptions,
  Plan, Corrections — as in the template below. Do not add other sections.
- Write the note at the level of the idea, not the code. Describe what
  changes in behavior/design, why, and the chosen approach. Do not
  enumerate files to edit and do not cite line numbers or code snippets;
  naming a module or component is fine when it is central to the idea.
  The bar: the user can read the note in a few minutes and understand
  the full design without opening the code.
- Do not edit anything in the repository until branch setup. Plan
  approval is necessary but not sufficient: the reply may first
  trigger reconciliation and another approval round (below). Silence
  or a question about the plan is not approval.
- Stop after writing the plan and ask the user to approve it.

### After plan approval, before Implementation

The approval reply may still shift something — an assumption overridden,
a plan step reshaped, a new constraint. Record those shifts in the note
**before** branch setup, otherwise the note silently drifts from reality:

- Reconcile `## Assumptions` and `## Plan` with the reply — remove
  or rewrite items the user overrode; add items the reply makes
  necessary: a plan step for a new constraint, an assumption for a
  new open point (by the same rules as in Questions). If a Plan step
  disappears, the remaining `- [ ]` list must still be a faithful
  execution sequence.
- A reconciled note is a plan version the user has not seen — the
  approval covered the pre-reconciliation text. Every version must be
  explicitly approved: if reconciliation changed anything, show the
  changed items in the conversation and stop for approval of the
  reconciled version. Repeat reconcile → approve until an approval
  reply shifts nothing.
- Only after the note matches reality and its current text is
  explicitly approved: proceed to branch setup.

## 3. Implementation

### Branch setup

Check git state first:

- "Clean" means: no staged changes, no unstaged modifications to tracked
  files. Untracked files are ignored — treat them as user's in-progress
  notes that have nothing to do with the task.
- If the repository is clean and the current branch is the default
  branch (`main` or whatever the remote HEAD points to), run
  `git fetch` and fast-forward it to its remote tracking branch
  before branching, so the new branch starts from the latest upstream
  state. Then create a new branch, record its name in the note's
  `branch:` field, and set `status: in-progress`.
  The branch name must not contain `/`. Do not include
  the issue id (from any tracking system) in the branch name — name it
  after what the change does, not what ticket it came from. The issue id
  belongs in the note's `task:` field.
- If the repository is not clean, the current branch is not the
  default branch, or the fast-forward cannot be completed (diverged
  history, no remote tracking branch, fetch failure), stop and notify
  the user instead of proceeding.

### During implementation

- Follow the approved plan.
- Keep changes focused.
- Prefer small, understandable edits.
- Keep code comments minimal. Default to none. Add a comment only when
  the WHY is non-obvious — a hidden constraint, a subtle invariant, a
  workaround for a specific bug, or behavior that would surprise a
  reader. Don't restate WHAT the code does (good names already do that),
  and don't reference the current task, fix, or callers ("added for X",
  "used by Y") — that belongs in the commit/PR, not the source.
- The `## Plan` and `## Assumptions` text is frozen from branch setup
  on. Never rewrite, add, or remove their items. The only allowed
  marks are status marks: `- [x]` on a completed plan step,
  strike-through on a plan step or assumption superseded by a
  correction.
- Record every correction the user gives during implementation in
  `## Corrections`: one line per correction, capturing its essence, not
  the full message. If a correction supersedes a plan step or an
  assumption, strike the superseded item through. `## Corrections` is
  a log, not a task list: entries never get completion marks. A
  correction acts in one of three ways: it reshapes how a frozen plan
  step is executed, voids a step or an assumption (marked by the
  strike-through), or adds work no step covers. In all three cases
  completion is gated by the `status: done` rule: every entry
  reflected in the implementation.
- If reality forces a deviation from the approved plan — a step turns out
  wrong, impossible, or insufficient — do not decide alone: stop, lay it
  out in the conversation, and let the user decide. Record the decision
  in `## Corrections` like any other correction.
- If corrections change the direction of the task rather than a detail,
  so the plan cannot be followed without changing it, stop, set
  `status: superseded` in the note, and tell the user so explicitly.
  This is not a plan edit: the note is closed, the task neither
  continues nor restarts in this agent context, and a superseded note
  is never an input to later work — not a plan to resume, not a draft
  to carry over. Whether and how the task restarts is the user's
  decision, not a workflow step.
- Run the relevant checks — fmt, linter, build, tests — as you work.
  If a check cannot be run, explain why and ask the user; do not search
  for workarounds. The user may run the checks themselves and report
  the results in the conversation — a check the user confirms passing
  counts as passed, including for `status: done`. If no automated
  checks exist, say what was verified manually.
- Set `status: done` only when every `## Plan` item is `- [x]` or
  struck through, every `## Corrections` entry is reflected in the
  implementation, and a final full run of the checks passes. Report
  the commands and results in the conversation. For each
  `## Corrections` entry, state in the conversation where the
  implementation reflects it. When no automated checks exist, the
  report of what was verified manually replaces the final run.
- Status marks, `## Corrections` entries, and the closing `status:`
  change (`done` or `superseded`) are the only note-keeping after
  branch setup.
- On `status: superseded`, the branch and the changes made on it stay
  as they are: deciding what to do with the work is the user's own
  responsibility, not a workflow step.

## Task note template

Use this structure for every task note:

```markdown
---
task:
repo:
branch:
status: planning
---

# Task: <title>

## Summary

## Context

## Assumptions

## Plan

- [ ] step 1
- [ ] step 2

## Corrections
```
