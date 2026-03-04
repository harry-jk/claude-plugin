---
name: Git Policy Enforcement
description: MUST be invoked before ANY git commit or push operation. No exceptions. This skill enforces project git policies including commit confirmation, message format, and attribution rules. Failure to invoke this skill before committing is a policy violation.
version: 0.1.0
---

## Purpose

Enforce git policies defined by `/policy-setup`. This skill automatically applies configured rules during git operations, ensuring consistent and compliant commits across the project.

## When to Use

- User is about to commit code
- User asks about git workflow or commit process
- Claude prepares a git commit
- User mentions committing changes
- Before executing `git commit` or `git push`

## How to Use This Skill

### Step 1: Load Policy Configuration

Before any git operation, load `.claude/git-policy.json`:

```json
{
  "version": "1.0",
  "projectType": "private",
  "policies": {
    "commitConfirmation": { "enabled": true },
    "commitMessageFormat": { "ticketMethod": "custom", "currentTicket": "PROJ-123" },
    "coAuthoredBy": { "method": "yes_no_email" }
  }
}
```

If file doesn't exist, guide user to run `/policy-setup` first.

### Step 2: Auto-generate and Format Commit Message

Analyze staged changes and auto-generate a commit message with policy format applied:

1. Review staged changes (file names, diff content)
2. Generate a conventional commit message based on changes
3. Apply `commitMessageFormat.ticketMethod` immediately:

#### For method: "none"
```
Generated: feat: add login
```

#### For method: "no_ticket"
```
Generated: [NT] feat: add quick improvement
```

#### For method: "branch"
```
Process:
1. Extract ticket from branch name (regex: [A-Z]+-\d+)
2. Prepend ticket to generated message
Generated: [PROJ-123] feat: add authentication
```

#### For method: "custom"
```
Process:
1. Check currentTicket in policy config
2. If not set, ask user: "What ticket/issue?"
3. Store answer in currentTicket
4. Prepend ticket to generated message
Generated: [PROJ-123] feat: add authentication
```

**If user already provided a commit message:**
- Validate it matches the required format
- If missing ticket prefix, prepend automatically
- If wrong conventional type, reject and ask to fix

### Step 3: Apply Co-Authored-By

If `coAuthoredBy.method !== "no"`:

Append attribution to commit message using **current model name and auto-detected email domain**:

**For method: "yes_no_email"** (private projects):
```
[existing commit message]

Co-Authored-By: [CURRENT_MODEL_NAME]
```

**For method: "yes_with_email"** (personal/public projects):
```
[existing commit message]

Co-Authored-By: [CURRENT_MODEL_NAME] <[AUTO_EMAIL]>
```

**Email auto-detection (based on current model):**
- Claude models (Anthropic) → noreply@anthropic.com
- Other models → Requires provider's official Co-Authored-By email to be configured separately
  (Note: Only Anthropic/Claude officially defines a noreply email address for AI attribution)

Note: Model name and email are determined at enforcement time, allowing attribution to automatically change if model changes between commits.

**Rules:**
- Always append to end of message
- Add blank line before attribution
- Never duplicate if already present
- Use exact model name

### Step 4: Apply Commit Confirmation

If `commitConfirmation.enabled === true`:

Use `AskUserQuestion` to confirm commit, showing the **fully formatted final message**:

```yaml
Q: "Ready to commit these changes?"
Header: "Commit Confirmation"
Options:
  - "Yes, commit now"
  - "Edit message"
  - "Cancel commit"
```

Display summary:
- Files changed
- Lines added/removed
- **Full final commit message** (with ticket prefix + Co-Authored-By applied):

```
[TEST] feat: add git policy system

Co-Authored-By: Claude Sonnet 4.6
```

Only proceed if user confirms "Yes, commit now".
If user selects "Edit message", accept new message and re-apply format validation.

### Step 5: Execute Commit

Once all validations pass and confirmations received:

1. Show final commit message
2. Execute git commit via MCP
3. Update `appliedAt` timestamp in policy config
4. Report success to user

## Enforcement Rules

### Commit Confirmation

| Enabled | Behavior |
|---|---|
| `true` | Prompt user before each commit/push with Ask tool |
| `false` | Proceed with commit without confirmation prompt |

### Message Format Validation

| Method | Validation | Action on Failure |
|---|---|---|
| none | Only Conventional type check | Reject, explain, request fix |
| no_ticket | Requires [NT] prefix | Reject, show format, request fix |
| branch | Extract from branch, validate | Extract, prepend, validate |
| custom | Requires currentTicket set | Ask user for ticket if missing |

### Co-Authored-By Application

| Method | Format | Appended |
|---|---|---|
| no | None | Not appended |
| yes_no_email | `Co-Authored-By: Claude Haiku 4.5` | Always |
| yes_with_email | `Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>` | Always |

## Common Scenarios

### Scenario 1: MVP Project with No Confirmation

```json
{
  "commitConfirmation": { "enabled": false },
  "commitMessageFormat": { "ticketMethod": "none" },
  "coAuthoredBy": { "method": "no" }
}
```

**Flow:**
1. User commits
2. Validate Conventional Commits type only
3. No confirmation needed
4. No ticket required
5. No attribution appended
6. Commit executes

### Scenario 2: Private Project with Ticket Tracking

```json
{
  "commitConfirmation": { "enabled": true },
  "commitMessageFormat": { "ticketMethod": "custom", "currentTicket": "PROJ-123" },
  "coAuthoredBy": { "method": "yes_no_email" }
}
```

**Flow:**
1. User prepares to commit
2. Auto-generate message, prepend [PROJ-123] ticket prefix
3. Append `Co-Authored-By: [CURRENT_MODEL]` (without email)
4. Show full final message in confirmation prompt
5. Execute commit with all rules applied

### Scenario 3: Open Source Project with Email Attribution

```json
{
  "commitConfirmation": { "enabled": false },
  "commitMessageFormat": { "ticketMethod": "branch" },
  "coAuthoredBy": { "method": "yes_with_email" }
}
```

**Flow:**
1. User commits from branch `feature/ISSUE-456-auth`
2. No confirmation needed (enabled: false)
3. Extract ticket: ISSUE-456
4. Validate message starts with Conventional type
5. Prepend [ISSUE-456] if missing
6. Append `Co-Authored-By: [CURRENT_MODEL] <noreply@anthropic.com>` (with email)
7. Execute commit

## Error Handling

### Policy File Missing

```
Error: .claude/git-policy.json not found

Action:
1. Suggest running /policy-setup
2. Offer to apply default policies
3. Ask if user wants to proceed without enforcement
```

### Message Format Violation

```
Error: Commit message does not match policy [ticketMethod: custom]

Current: "fix: resolve bug"
Expected: "[PROJ-123] fix: resolve bug"

Action:
1. Show expected format
2. Suggest correction
3. Ask user to fix message
4. Retry validation
```

### Ticket Not Set (custom method)

```
Status: Ticket not configured for this session

Question: "What ticket are you working on?"
Action:
1. Store user response in currentTicket
2. Update policy config
3. Retry commit
```

## Additional Resources

### Reference Files

For detailed enforcement rules and scenarios:
- **`references/enforcement-rules.md`** - Complete validation specifications
