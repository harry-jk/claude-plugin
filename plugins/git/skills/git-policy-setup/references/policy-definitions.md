# Git Policy Definitions

Complete specifications for each policy option.

## 1. Commit Confirmation Policy

### enablement Criteria

| Project Type | Recommended | Rationale |
|---|---|---|
| Production | `true` | Safety critical, prevent accidental commits |
| Team Projects | `true` | Coordination, prevent merge conflicts |
| Important Features | `true` | Milestone importance, review step |
| MVP | `false` | Speed over safety |
| Prototypes | `false` | Experimentation priority |
| Personal Solo | `false` | Single decision maker |

### Implementation

When `enabled: true`:
- Before each `git commit` or `git push`, prompt user with Ask tool
- Display summary of changes
- Require explicit "yes" to proceed
- Option to cancel or review before committing

When `enabled: false`:
- Proceed with commits without confirmation
- Still apply other policies (message format, Co-Authored-By)

## 2. Commit Message Format Policy

### Conventional Commits (Always Required)

All commits start with conventional prefix:

```
feat:     New feature
fix:      Bug fix
docs:     Documentation
style:    Code style (no logic change)
refactor: Code reorganization (no logic change)
perf:     Performance improvement
test:     Test addition/modification
chore:    Build/tool/dependency changes
ci:       CI/CD configuration
```

Example: `feat: add user authentication`

### Ticket Method Options

#### Option 1: none

**Format:** `[prefix] [type]: [description]`

Example:
```
feat: add login feature
fix: resolve memory leak in caching
docs: update README with setup instructions
```

**When to use:**
- No ticket system in place
- Ticket references optional
- Internal/prototype projects
- Simple feature tracking

**Validation:** Only Conventional Commits check

---

#### Option 2: no_ticket

**Format:** `[NT] [type]: [description]`

Example:
```
[NT] feat: add quick style improvement
[NT] fix: resolve typo in comments
[NT] docs: clarify installation steps
```

**When to use:**
- Using ticket system but issue has no ticket
- Quick fixes, typos, or minor improvements
- Distinguishes ticketed vs non-ticketed work
- Maintains consistency with ticket-required projects

**Validation:**
- Must start with `[NT]`
- Followed by Conventional Commits type

---

#### Option 3: branch

**Format:** `[TICKET-XXX] [type]: [description]`

Example:
```
Branch: feature/PROJ-123-add-login
Commit: [PROJ-123] feat: add user authentication

Branch: bugfix/JIRA-456-cache-leak
Commit: [JIRA-456] fix: resolve memory leak
```

**Prerequisites:**
- Branch naming convention must exist
- Branch names must contain extractable ticket ID
- Pattern: `feature/TICKET-123-description` or similar

**Extraction algorithm:**
1. Get current branch name: `git rev-parse --abbrev-ref HEAD`
2. Extract ticket pattern (uppercase + dash + numbers): `[A-Z]+-\d+`
3. Validate ticket exists in extracted string
4. Insert into commit message

**When to use:**
- Branch naming conventions already established
- Project management tool (Jira, GitHub Projects) integration
- Automatic tracking via branch-ticket mapping
- Teams with discipline around branch naming

**Validation:**
- Extract ticket from branch
- Verify format `[TICKET-XXX]`
- Ensure Conventional Commits type follows

---

#### Option 4: direct

**Format:** `[TICKET-XXX] [type]: [description]`

Example:
```
Session start:
  Q: "What ticket/issue are you working on?"
  A: "PROJ-123"

First commit: [PROJ-123] feat: add authentication
Second commit: [PROJ-123] fix: handle edge case
Third commit: [PROJ-123] test: add unit tests
```

**Session workflow:**
1. At work session start, prompt: "What ticket/issue?"
2. Store ticket in policy config: `currentTicket: "PROJ-123"`
3. All subsequent commits use this ticket
4. When starting new task, update ticket

**When to use:**
- Single feature/task per session
- Focused work periods
- Ticket required for all work
- Manual control over ticket assignment

**Validation:**
- Check `currentTicket` in config
- Verify format `[TICKET-XXX]`
- Ensure Conventional Commits type follows

---

## 3. Co-Authored-By Policy

### Purpose

Add attribution for AI-assisted development:

```
feat: implement user authentication

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>
```

### Implementation

Location: Last line of commit message, separated by blank line.

### Private Projects (includeEmail: false)

**Format:**
```
Co-Authored-By: Claude Haiku 4.5
```

**Reason:**
- Prevent unintended GitHub account linking
- Noreply email may cause authentication issues
- Cloud-internal projects don't need public attribution

**When to apply:**
- Company/internal repositories
- Private GitHub repositories
- Non-public work

### Personal Projects (includeEmail: true)

**Format:**
```
Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>
```

**Reason:**
- Proper public attribution
- GitHub recognizes format with email
- Transparent about AI contribution
- Community standards compliance

**When to apply:**
- Open source projects
- Public repositories
- Published work

### Model Names

Use actual model name in commitment:
- `Claude Haiku 4.5`
- `Claude Sonnet 4.6`
- `Claude Opus 4.6`

Never use:
- Generic "Claude"
- User names
- Team names

### Enforcement Rules

1. **Always append** when enabled
2. **Place at end** of commit message
3. **Blank line separation** from main message
4. **Exact format** - no variations

Example full commit:

```
feat: add authentication system

Implement user login/logout with JWT tokens.
Add password hashing and validation.
Support remember-me functionality.

Co-Authored-By: Claude Haiku 4.5
```

---

## Configuration Storage

All policies stored in `.claude/git-policy.json`:

```json
{
  "version": "1.0",
  "projectType": "private",
  "policies": {
    "commitConfirmation": {
      "enabled": true
    },
    "commitMessageFormat": {
      "ticketMethod": "direct",
      "currentTicket": "PROJ-123"
    },
    "coAuthoredBy": {
      "enabled": true,
      "includeEmail": false
    }
  },
  "createdAt": "2026-03-04",
  "appliedAt": "2026-03-04T10:30:00Z"
}
```

## Policy Application

Policies are applied by `git-policy-enforcement` skill:
- Loaded from `.claude/git-policy.json`
- Enforced during commit operations
- Violations trigger guidance/corrections
- Can be updated anytime with `git-policy-setup`
