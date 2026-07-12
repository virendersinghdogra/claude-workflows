You MUST read CLAUDE.md before starting — it defines all repository conventions and coding patterns.

## Tool Usage

- Use Grep, Glob, and Read tools for all file searching and reading — NEVER use Bash for these operations.
- Bash is ONLY for build, lint, typecheck, and git commands listed in allowedTools.
- Bash commands in CI CANNOT use pipes, command substitution, or shell redirection.
- If a Bash command is denied, do NOT retry variations — simplify the command or switch to a dedicated tool immediately.
- You MUST Read every file before you Edit it — no exceptions. When editing multiple files, Read each one immediately before editing it.

## CI Rules

- Dependencies are already installed — do NOT run install commands.
- For bulk edits, work in batches of 5 files: Read file, Edit file, repeat for each file in the batch.
- Do NOT use Task subagents for file editing — they cannot use Edit, Grep, or Glob.
- Do NOT use mcp__github_file_ops__commit_files — use git commands directly.
- Do NOT use TodoWrite — it wastes turns. Instead, outline your full plan (explore → edit → verify → commit) in a single text response before starting work, then execute without progress-tracking tool calls.

## Efficiency

- Minimize turns: chain Bash commands with `&&`, read multiple related files in parallel, batch similar edits.
- Plan your full approach (explore → edit → verify → commit) before making changes.
- Before creating a new file, read 1-2 existing files of the same kind to match patterns exactly.

## Implementation Standards

- Do NOT add dependencies unless the task explicitly requires it.
- Follow existing patterns. No new conventions or abstractions.
- Implement the minimal change. No refactors or unnecessary additions.
- Do not break existing interfaces or public APIs without explicit instruction.
- Add or update unit tests for changed behavior — verify edge cases, error paths, state transitions, not just happy paths.

## Git Commit Rules

- Run `git add` and `git commit` as **separate** commands — never chain with `&&`.
- **NEVER use HEREDOC or multi-line strings in git commit commands** — the Bash permission pattern cannot match them and they will be denied.
- Instead, write the commit message to `/tmp/commit-msg.txt` using the Write tool, then run: `git commit --file /tmp/commit-msg.txt`
- For review bodies, write the body to a temp file and use `--body-file` (PR creation is handled by the workflow — see "Opening a PR").
- Write temp files to `/tmp/` and do NOT clean them up — runners are ephemeral.

## Opening a PR

- NEVER run `gh pr create` — its multi-line `--body` cannot match the Bash permission pattern and will be denied.
- To open a PR: commit, push the branch, then write the exact branch name to `/tmp/pr-branch.txt` (single line), the title to `/tmp/pr-title.txt` (single line), and the body to `/tmp/pr-body.txt` using the Write tool. The workflow opens the PR from those files.
