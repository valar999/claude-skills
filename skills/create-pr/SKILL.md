---
name: create-pr
description: Create a GitHub pull request for the current branch; the PR message is the commit message with paragraphs unwrapped, the signature stripped, and a Closes line appended. Invoke only on explicit /create-pr request.
---

# Create PR

Create a pull request for the current branch with `gh pr create`.

## Preconditions

- The current branch is not the default branch (the one remote HEAD points
  to; detect via `git symbolic-ref refs/remotes/origin/HEAD`).
- This machine never pushes. Run `git fetch origin <branch>` and compare
  `origin/<branch>` with local HEAD:
  - remote branch missing or pointing at a different commit → stop and ask
    the user to push the branch from their machine, then re-run the skill.
- The commit message source is the branch's single commit ahead of the
  default branch. If the branch is several commits ahead, stop and ask the
  user which commit message to use.

## PR title

The commit subject line (`git log -1 --format=%s`), verbatim.

## PR body

The commit message body (`git log -1 --format=%b`), transformed:

1. Drop the trailing `Co-Authored-By: …` trailer line(s).
2. Unwrap paragraphs: within each paragraph (a block of lines separated by
   blank lines) replace line breaks with single spaces, so every paragraph
   becomes one line. Blank lines between paragraphs stay. For plain-prose
   bodies this one-liner does it:

       git log -1 --format=%b | grep -v '^Co-Authored-By:' \
         | awk 'BEGIN{RS=""; ORS="\n\n"} {gsub(/\n/," "); print}'

   If the body contains list items or indented/code lines, keep those on
   their own lines and unwrap only the prose paragraphs (do it by hand).
3. If the task has an issue, append a final paragraph: `Closes #<NN>`.
   Take the issue id from the task note in `~/src/ai-tasks/` whose
   `branch:` field matches the current branch (`task:` field), falling
   back to an `issue #NN` reference in the commit message. No issue — no
   line.
4. Nothing else: no generated-with footer, no co-author line, no
   signature.

## Create

Write the body to a temp file and run:

    gh pr create --base <default-branch> --head <branch> \
      --title "<subject>" --body-file <file>

Report the PR URL. Do not push, do not merge, do not enable auto-merge.
