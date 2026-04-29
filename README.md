# Claude Skills

Personal collection of [Claude Code](https://docs.claude.com/en/docs/claude-code) skills.

## Layout

```
skills/
  <skill-name>/
    SKILL.md         # required — frontmatter + body
    ...              # optional assets, scripts, templates
```

Each subdirectory of `skills/` is a self-contained skill. The directory name
becomes the skill name that Claude Code picks up.

## Install

Symlink every skill in this repo into `~/.claude/skills/`:

```sh
./install.sh
```

Re-run after `git pull` to pick up new skills. Existing real directories under
`~/.claude/skills/` are not touched.

To install into a different location, set `CLAUDE_SKILLS_DIR`:

```sh
CLAUDE_SKILLS_DIR=/path/to/skills ./install.sh
```

## Skills

- [coding-workflow](skills/coding-workflow/) — 6-phase workflow (Questions → Plan → Implementation → Verification → Review → Commit/PR) for non-trivial coding tasks. Triggered by `Task:` prefix or `/coding-workflow`.

## Adding a new skill

1. `mkdir skills/<name>`
2. Create `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`)
   and the skill body.
3. Add an entry to the list above.
4. `./install.sh`
