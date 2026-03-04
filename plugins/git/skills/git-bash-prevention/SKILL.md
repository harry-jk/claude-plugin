---
name: Git Bash Prevention
description: This skill should be used when the user attempts git operations via bash, or when Claude detects bash being used for git commands. Automatically detects direct git command usage and suggests using git MCP instead, providing equivalent MCP tool calls.
version: 0.1.0
---

## Purpose

Prevent direct bash git commands and guide users to use git MCP instead. This skill automatically detects when bash is used for git operations and provides equivalent MCP alternatives, ensuring consistent tool usage and policy compliance.

## When to Use

- User attempts `git commit`, `git push`, `git pull`, etc. via bash
- User writes bash script containing git commands
- Claude detects `git ` command in bash execution
- User asks about running git from terminal
- PreToolUse hook detects bash tool with git commands

## How to Use This Skill

### Step 1: Detect Git Commands in Bash

Monitor for git commands in bash execution:

```bash
# Detected patterns:
git commit
git push
git pull
git branch
git merge
git status
git log
git add
git checkout
git reset
git revert
git clean
git restore
[any other git command]
```

Detection triggers when:
- User calls Bash tool
- Command contains git as a command (any context):
  - Direct: `git status`
  - Piped: `cat file | git apply`
  - Chained: `cd repo; git push`
  - Substituted: `$(git status)` or `` `git log` ``
  - Subshell: `(git commit)` or `{ git status; }`

### Step 2: Classify Command Type

Determine if command is:

**Allowed (query-only):**
- `git status`
- `git log`
- `git diff`
- `git blame`
- `git show`
- `git branch -l` (list only)

**Actionable (requires MCP):**
- `git add`
- `git commit`
- `git push`
- `git pull`
- `git merge`
- `git rebase`
- `git reset`
- `git checkout`
- `git stash`
- `git branch` (create/delete)
- `git tag`
- `git worktree`
- Any destructive operation

**Forbidden (always block):**
- `git reset --hard`
- `git clean -f`
- `git revert`
- `git restore` (not `--staged`)
- Operations that risk data loss

### Step 3: Provide MCP Alternative

When actionable git command detected:

1. **Acknowledge the intent**
   ```
   Detected: git commit -m "Fix bug"
   ```

2. **Explain why MCP is better**
   ```
   Git MCP provides:
   - Policy enforcement (commit messages, confirmations)
   - Automatic attribution (Co-Authored-By)
   - Ticket tracking integration
   - Safety checks and validations
   ```

3. **Show MCP equivalent**
   ```
   Instead of:
   $ git commit -m "Fix bug"

   Use git MCP:
   > Call Bash tool? No, use Git MCP tool instead
   ```

4. **Execute via MCP** (if appropriate)
   ```
   Using git MCP commit tool with:
   - Message: "Fix bug"
   - Apply policies
   - Enforce format rules
   ```

### Step 4: Handle Special Cases

#### Case 1: Git config commands
```bash
git config user.name "Name"
```
**Action:** Suggest configuring via project setup instead of bash

#### Case 2: Piped git commands
```bash
echo "message" | git commit -F -
```
**Action:** Use git MCP directly, avoid pipes

#### Case 3: Git in scripts
```bash
#!/bin/bash
git commit -m "Auto commit"
```
**Action:** Convert script to use git MCP or execute commands directly

#### Case 4: Complex git workflows
```bash
git log --oneline | grep "feat:" | head -5
```
**Action:** Use git MCP query tools directly

## Enforcement Strategy

### Level 1: Warning (Informational)

For query-only commands (status, log, diff):
```
ℹ️  Using bash for git queries
You can use git MCP for better integration:
  $ git-mcp status (Shows formatted output)
```

**Action:** Suggest but allow

### Level 2: Guidance (Actionable)

For actionable commands (commit, push, branch):
```
⚠️  Bash git command detected: git commit
This bypasses:
  - Commit confirmation checks
  - Message format validation
  - Automatic attribution
  - Policy enforcement

Use git MCP instead for:
  - Safety checks
  - Policy compliance
  - Automatic formatting
```

**Action:** Redirect to MCP, don't execute bash

### Level 3: Block (Destructive)

For forbidden operations (reset --hard, clean -f, revert):
```
❌ Destructive git operation blocked: git reset --hard

This command is forbidden because:
  - Irreversible data loss risk
  - No recovery mechanism
  - Destructive operations not supported

Use git MCP safely or alternative approach.
```

**Action:** Block execution entirely, no override available

## MCP Tool Mapping

Common git commands mapped to MCP equivalents:

| Bash Command | MCP Tool | Notes |
|---|---|---|
| `git status` | query status | Query only |
| `git log` | query log | Query only |
| `git diff` | query diff | Query only |
| `git commit` | execute commit | Applies policies |
| `git add` | execute stage | Applies policy checks |
| `git push` | execute push | Requires confirmation |
| `git pull` | execute pull | Updates working tree |
| `git branch` | execute branch | Create/delete |
| `git checkout` | execute checkout | Switch branch |
| `git stash` | execute stash | Temporary storage |
| `git tag` | execute tag | Create/delete tags |
| `git reset --hard` | BLOCKED | Destructive |
| `git clean -f` | BLOCKED | Destructive |

## Implementation via Hook

This skill is typically triggered by **PreToolUse hook**:

```yaml
Event: PreToolUse
Condition: tool === "Bash" AND command contains "git "
Action: Invoke git-bash-prevention skill
```

Hook can:
1. Detect git command in bash
2. Load this skill
3. Check command type
4. Allow/warn/block
5. Provide MCP alternative

## User Guidance

### For Query Operations

```
You're running: git log --oneline

This works fine in bash! If you want:
  • Formatted output: Use git MCP
  • Integration with workflow: Use git MCP
  • Otherwise: This bash command is OK
```

### For Actionable Operations

```
You're running: git commit -m "Fix bug"

⚠️  This bypasses git policies!

Better approach:
  1. Use git MCP commit tool
  2. Policies enforced automatically
  3. Message validated
  4. Attribution added

Should I use git MCP instead? (Yes/No)
```

### For Forbidden Operations

```
You're running: git reset --hard origin/main

❌ This is blocked!

Reason: Irreversible data loss risk - not supported

Your options:
  1. Use git MCP safe alternatives
  2. Use git revert (creates new commit)
  3. Contact team lead for override
```

## Additional Resources

### Reference Files

For detailed bash prevention rules:
- **`references/git-bash-rules.md`** - Complete bash git detection patterns
