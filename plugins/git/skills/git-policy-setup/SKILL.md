---
name: Git Policy Setup
description: This skill should be used when the user starts a new project, begins a new task, or asks to configure git policies. Helps define project-specific git rules and policies that will be enforced during development.
version: 0.1.0
---

## Purpose

Configure git policies for the current project or task. This skill sets up rules that determine how git operations (commits, messages, confirmations) should be handled, enabling consistent enforcement across work sessions.

## When to Use

- User starts a new project or task
- User asks "set up git policy", "configure git rules", "define git workflow"
- User asks "change git policy", "update git rules", "modify commit format"
- User mentions working on a new feature branch or task
- Beginning a work session to establish project conventions

## How to Use This Skill

### Step 0: Check for Existing Policy

Before gathering preferences, check if `.claude/git-policy.json` already exists:

**If file exists**, read current settings and ask whether to create new or edit existing:

```yaml
Q: "Git policy already configured. What would you like to do?"
Header: "Policy Found"
Options:
  - "Edit existing policy"
  - "Create new policy (overwrite)"
```

**If "Edit existing policy"** selected:
- Display current settings clearly:
  ```
  Current policy:
  - Commit confirmation: enabled
  - Message format: custom [PROJ-123]
  - Co-Authored-By: name only
  ```
- Ask which item to change:
  ```yaml
  Q: "Which policy would you like to change?"
  Header: "Edit Policy"
  Options:
    - "Commit confirmation (currently: enabled)"
    - "Message format (currently: custom [PROJ-123])"
    - "Co-Authored-By (currently: name only)"
    - "All settings (reconfigure everything)"
  ```
- Only show AskUserQuestion for the selected item(s)
- Update only changed fields in git-policy.json, keep rest intact

**If "Create new policy"** or file doesn't exist, proceed to Step 1.

### Step 1: Gather Policy Preferences

Use `AskUserQuestion` to gather policy preferences. Present clear choices for each policy:

1. **Commit Confirmation Policy**
   - Does this project require explicit confirmation before committing?
   - Enable for: Careful projects, production code, teams
   - Disable for: MVP, prototypes, solo work

2. **Commit Message Format Policy**
   - How should commit messages be structured?
   - Options:
     - "none": No ticket requirements
     - "no_ticket": Use [NT] for issues without tickets
     - "branch": Auto-extract ticket from branch name
   - Additionally: Users can select "Other" to provide a custom ticket reference

3. **Co-Authored-By Policy**
   - Should commit messages include Co-Authored-By?
   - Options:
     - "no": Skip Co-Authored-By
     - "yes_no_email": Include without email (for private projects)
     - "yes_with_email": Include with email (for personal/public projects)

### Step 2: Save Policy Configuration

Store policy configuration in `.claude/git-policy.json`:

```json
{
  "version": "1.0",
  "projectType": "private" | "personal",
  "policies": {
    "commitConfirmation": {
      "enabled": true | false
    },
    "commitMessageFormat": {
      "ticketMethod": "none" | "no_ticket" | "branch" | "custom",
      "currentTicket": "PROJ-123"
    },
    "coAuthoredBy": {
      "method": "no" | "yes_no_email" | "yes_with_email"
    }
  },
  "createdAt": "2026-03-04",
  "appliedAt": null
}
```

### Step 3: Confirm and Document

Summarize configured policies to the user:
- Which policies are enabled
- What format will be enforced
- When enforcement begins

## Policy Definitions

### Commit Confirmation

**What it does:** Requires explicit user confirmation before executing commit/push operations.

**When to enable:**
- Production codebases
- Team projects
- Important milestones
- When mistakes are costly

**When to disable:**
- MVP projects
- Personal experiments
- Rapid prototyping
- Solo development

### Commit Message Format

Determines ticket/reference structure in commit messages. Conventional Commits (`feat:`, `fix:`, `docs:`) are always required.

**Options:**

1. **none** - Ticket excluded
   - Format: `feat: add login`
   - Use when: No ticket system or optional tickets

2. **no_ticket** - Explicit non-ticket flag
   - Format: `[NT] feat: add login`
   - Use when: Issue has no ticket but needs marking

3. **branch** - Auto-extract from branch name
   - Branch: `feature/PROJ-123-login`
   - Commit: `[PROJ-123] feat: add login`
   - Use when: Branch naming convention exists

4. **custom** - User provides custom ticket reference
   - User provides via text input: `PROJ-123`
   - All commits: `[PROJ-123] feat: add login`
   - Use when: Working on single feature/task without branch convention

### Co-Authored-By

Adds collaborator attribution to commits.

**Options:**

1. **no** - Skip Co-Authored-By
   - Format: No attribution added
   - Use when: Solo work, no attribution needed

2. **yes_no_email** - Include without email
   - Format: `Co-Authored-By: [MODEL_NAME]`
   - Use when: Private projects (prevents unintended GitHub account linking)
   - Note: Model name is determined at enforcement time, allowing attribution to change if model changes

3. **yes_with_email** - Include with email
   - Format: `Co-Authored-By: [MODEL_NAME] <[MODEL_EMAIL]>`
   - Model provides both name and email automatically:
     - Each AI model provides its own official attribution email
     - No user input required - handled completely by the model providing its own information
   - Use when: Personal/public projects (proper attribution for public contribution)
   - Note: Model name and email are determined at enforcement time by the model itself, allowing attribution to automatically change if model changes between commits

## Integration with Enforcement

Once configured, `git-policy-enforcement` skill will:
- Load this policy configuration
- Enforce commit confirmation prompts
- Validate commit message formats
- Apply Co-Authored-By formatting
- Block policy violations with guidance

## Additional Resources

### Reference Files

For detailed policy patterns and enforcement rules:
- **`references/policy-definitions.md`** - Complete policy specifications
