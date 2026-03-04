# Git Bash Detection and Prevention Rules

Complete specifications for detecting git commands in bash and preventing direct usage.

## Detection Patterns

### Git Command Recognition

**Pattern:** Command starts with `git` followed by space

```regex
^\s*git\s+[a-z\-]+
```

**Examples detected:**
```bash
git status
git commit -m "message"
git push origin main
git log --oneline
git checkout -b feature/PROJ-123
git reset --hard origin/main
```

**Examples NOT detected:**
```bash
echo "git push" # string literal
/usr/bin/git push # full path (also detected)
${GIT_EXECUTABLE} push # variable
```

### Command Extraction

When detected, extract:
1. **Command type:** `git`
2. **Subcommand:** `commit`, `push`, `status`, etc.
3. **Arguments:** All flags and parameters
4. **Full command:** Entire string for reference

```bash
Detected: "git commit -m 'Fix bug'"
└─ Subcommand: commit
└─ Arguments: ['-m', 'Fix bug']
└─ Type: Actionable
```

---

## Command Classification

### Query Commands (Read-Only)

These retrieve information without modifying state:

| Command | Flags | Read-Only | Status |
|---|---|---|---|
| `git status` | any | ✅ | Allow |
| `git log` | any | ✅ | Allow |
| `git diff` | any | ✅ | Allow |
| `git blame` | any | ✅ | Allow |
| `git show` | any | ✅ | Allow |
| `git branch -l` | `-l`, `--list` only | ✅ | Allow |
| `git remote -v` | any | ✅ | Allow |
| `git tag` | no flags (list only) | ✅ | Allow |
| `git config --get` | `--get` only | ✅ | Allow |

**Behavior:** Warn user but allow execution

**Warning message:**
```
ℹ️  Git bash query command detected: git log

You can use git MCP for better integration and output formatting.
This command is allowed, but consider:
  • Better formatting with git MCP
  • Integration with workflows
  • Consistent output parsing

Continue with bash? Or use git MCP instead?
```

---

### Actionable Commands (State-Changing)

These modify the repository state:

| Command | Risk | Status |
|---|---|---|
| `git add` | Low | Require MCP |
| `git commit` | Medium | Require MCP |
| `git push` | Medium | Require MCP |
| `git pull` | Medium | Require MCP |
| `git fetch` | Low | Require MCP |
| `git branch -d` | Medium | Require MCP |
| `git branch -D` | High | Require MCP |
| `git checkout` | Medium | Require MCP |
| `git switch` | Medium | Require MCP |
| `git merge` | High | Require MCP |
| `git rebase` | High | Require MCP |
| `git stash` | Low | Require MCP |
| `git tag -a` | Low | Require MCP |
| `git worktree add` | Low | Require MCP |
| `git worktree remove` | Low | Require MCP |
| `git cherry-pick` | High | Require MCP |

**Behavior:** Redirect to MCP, don't execute bash

**Guidance message:**
```
⚠️  Bash git command detected: git commit

This bypasses important protections:
  ✗ No commit confirmation checks
  ✗ No message format validation
  ✗ No automatic attribution
  ✗ No policy enforcement

Recommended: Use git MCP instead for:
  ✅ Automatic policy enforcement
  ✅ Message validation
  ✅ Safe confirmations
  ✅ Consistent formatting

MCP equivalent:
  > Execute git commit with MCP

Should I use git MCP? (Yes/No)
```

---

### Forbidden Commands (Destructive)

These can cause data loss or irreversible changes:

| Command | Reason | Status |
|---|---|---|
| `git reset --hard` | Irreversible data loss | Block |
| `git reset --mixed` | State change risk | Block |
| `git clean -f` | Deletes untracked files | Block |
| `git clean -fxd` | Deletes all untracked | Block |
| `git revert` | Can be destructive | Block |
| `git restore` (without `--staged`) | Discards changes | Block |
| `git checkout -- .` | Discards all changes | Block |
| `git push --force` | Rewrites history | Block |
| `git push --force-with-lease` | Rewrites history | Block |

**Behavior:** Block execution with explanation

**Block message:**
```
❌ Destructive git operation blocked: git reset --hard

This command is forbidden because:
  • Irreversible data loss risk
  • No recovery mechanism
  • Destructive operations not supported

Allowed alternatives:
  1. git revert (creates new commit, safer)
  2. git reset --soft (keeps changes staged)
  3. Contact team lead for override

Decision: Operation blocked for safety
```

---

## Detection Context

### Hook Integration

**PreToolUse Hook:**
```
Event: Tool called with Bash
Check: Command contains "git "
If true:
  - Classify command type
  - Apply appropriate action (allow/warn/block)
  - Provide MCP alternative
```

### Timing

**When to detect:**
- Before bash execution
- Check command in PreToolUse hook
- Don't execute if should be blocked
- Suggest MCP alternative instead

**Timeline:**
```
User: "Run git push"
↓
Claude prepares bash command
↓
PreToolUse hook triggers
↓
git-bash-prevention skill loads
↓
Classify: "push" = actionable
↓
Action: Block, suggest MCP
↓
User responds with "Use MCP" or "Cancel"
```

---

## Detection Accuracy

### True Positives (Correctly Detected)

```bash
git status                    ✅
git commit -m "test"          ✅
git push origin main          ✅
GIT_WORK_TREE=/path git add . ✅
/usr/local/bin/git log       ✅
```

### False Positives (Should NOT detect)

```bash
echo "git push"               ❌ (string literal)
git_custom_function push      ❌ (custom function)
"git status"                  ❌ (quoted string)
# git commit                  ❌ (comment)
```

**Prevention:**
- Don't match quoted strings
- Don't match after `#` (comments)
- Don't match in strings (backticks, quotes)
- Require `git ` with space

---

## MCP Tool Equivalents

When directing to MCP, provide specific equivalent:

| Bash Command | MCP Equivalent | Notes |
|---|---|---|
| `git status` | git-mcp status | Formatted output |
| `git log` | git-mcp log | Query tool |
| `git commit` | git-mcp commit | With policies |
| `git push` | git-mcp push | With confirmation |
| `git pull` | git-mcp pull | Safe update |
| `git add` | git-mcp add | Stage changes |
| `git branch -d` | git-mcp branch delete | Safe deletion |
| `git checkout` | git-mcp checkout | Branch switch |
| `git merge` | git-mcp merge | Controlled merge |
| `git rebase` | git-mcp rebase | Safer rebase |
| `git worktree add` | git-mcp worktree add | Worktree support |
| `git diff` | git-mcp diff | Query tool |
| `git log -p` | git-mcp log patch | Formatted patch |
| `git blame` | git-mcp blame | Annotated view |

---

## Special Cases

### Git Aliases

```bash
git st  # alias for status
git co  # alias for checkout
```

**Detection:** May not detect aliases

**Handling:**
- Ask user to expand alias
- Or suggest using MCP
- Not critical (usually query commands)

### Submodules

```bash
git submodule update --recursive
```

**Detection:** ✅ Detected as `submodule` subcommand

**Classification:** Actionable (risky)

**Action:** Redirect to MCP or warn

### Conditional Git Commands

```bash
if [ condition ]; then
  git commit -m "test"
fi
```

**Detection:** ✅ Detected inside condition

**Action:** Warn about git in conditional

### Piped Git Commands

```bash
git log --oneline | grep "feat"
```

**Detection:** ✅ Detected first part

**Classification:** Query (log is read-only)

**Action:** Warn, allow (piping to grep is safe)

### Git Inside Functions/Scripts

```bash
function auto_commit {
  git commit -m "$1"
}
```

**Detection:** ✅ Detected in function body

**Action:** Suggest using MCP instead of script

---

## User Responses

### If User Agrees to Use MCP

```
User: "Yes, use MCP instead"
↓
Execute git operation via git MCP tool
Apply policies and validation
Report success
```

### If User Wants to Proceed with Bash

```
User: "Proceed with bash anyway"
↓
For query commands: Allow and execute
For actionable: Warn again, allow if user confirms
For destructive: Block completely, no override option
```

### If User Cancels

```
User: "Cancel"
↓
Don't execute bash command
Stop git operation
Return to user
```

---

## Logging and Reporting

### What to Log

```
Timestamp: 2026-03-04T10:30:00Z
Event: Git bash command detected
Command: git commit -m "Fix bug"
Subcommand: commit
Classification: Actionable
Action: Redirected to MCP
User response: Accepted MCP
Outcome: Executed via git MCP
```

### Reporting

- Track patterns of direct bash usage
- Identify most-used git commands in bash
- Report to user for awareness
- Help optimize skill usage
