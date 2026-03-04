# Enforcement Rules and Validation

Detailed specification for policy enforcement during git operations.

## Commit Confirmation Enforcement

### When Enabled

**Trigger:** Before any `git commit` or `git push` operation

**Flow:**
```
User: Ready to commit
↓
Load policy.commitConfirmation.enabled
↓
If enabled:
  - Gather git changes (status, diff summary)
  - Display summary to user
  - Use Ask tool: "Confirm commit?"
  - Wait for user response
↓
If confirmed:
  - Proceed to message validation
If cancelled:
  - Stop, no commit
If "review first":
  - Show detailed diff
  - Repeat confirmation
```

### Ask Tool Implementation

```yaml
Question: "Ready to commit these changes?"

Options:
  1. "Yes, commit now"
  2. "Show changes first"
  3. "Cancel commit"

Display (always):
  - Files changed count
  - Lines added/deleted
  - Branch name
  - Commit message preview (if prepared)
```

### When Disabled

Skip confirmation, proceed directly to message validation.

---

## Commit Message Format Enforcement

### Conventional Commits (Always)

**Rule:** First line must start with conventional type

**Valid types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Code style (no logic)
- `refactor:` - Code reorganization
- `perf:` - Performance
- `test:` - Test changes
- `chore:` - Build/tool/dependency
- `ci:` - CI/CD changes

**Pattern:**
```
^(feat|fix|docs|style|refactor|perf|test|chore|ci):.+
```

**Valid examples:**
```
feat: add user authentication
fix: resolve memory leak
docs: update setup guide
refactor: simplify cache logic
```

**Invalid examples:**
```
add user authentication  # Missing type
feat add authentication  # Missing colon
FEAT: wrong case        # Wrong case
feat:                   # Missing description
```

**Validation action:**
- ✅ Passes: Continue to ticket validation
- ❌ Fails: Reject, show examples, request fix

---

### Ticket Method: none

**Requirement:** Only Conventional Commits type check

**Pattern:**
```
^(feat|fix|docs|style|refactor|perf|test|chore|ci):.+
```

**Valid:**
```
feat: add login feature
fix: resolve null pointer
docs: clarify setup steps
```

**Invalid:**
```
add login feature  # Missing type
feat: [PROJ-123] add login  # Has ticket when not expected
```

**Enforcement:**
```
1. Check message format
2. If matches pattern: ✅ Pass
3. If doesn't match: ❌ Reject
   - Explain why
   - Show valid format
   - Request correction
```

---

### Ticket Method: no_ticket

**Requirement:** Starts with `[NT]`, followed by Conventional Commits

**Pattern:**
```
^\[NT\]\s+(feat|fix|docs|style|refactor|perf|test|chore|ci):.+
```

**Valid:**
```
[NT] feat: quick styling fix
[NT] fix: typo in comments
[NT] docs: update readme
```

**Invalid:**
```
feat: quick fix  # Missing [NT]
[NT]feat: fix  # No space after [NT]
[NONE] feat: fix  # Wrong placeholder
NT feat: fix  # Missing brackets
```

**Enforcement:**
```
1. Check for [NT] prefix
2. If missing:
   ❌ Reject, suggest: [NT] feat: message

3. If present:
   - Validate space after [NT]
   - Validate Conventional type follows
   - If all valid: ✅ Pass
   - Else: ❌ Reject with examples
```

---

### Ticket Method: branch

**Requirement:** Extract ticket from branch name, prepend to message

**Process:**

1. **Get current branch**
   ```bash
   git rev-parse --abbrev-ref HEAD
   ```
   Output: `feature/PROJ-123-login`

2. **Extract ticket** (pattern: `[A-Z]+-\d+`)
   ```
   Branch: feature/PROJ-123-add-login
   Extract: PROJ-123

   Branch: bugfix/JIRA-456-fix-cache
   Extract: JIRA-456
   ```

3. **Validate extraction**
   ```
   If extracted:
     Continue to validation
   If NOT extracted:
     ❌ Error: Can't extract ticket from branch
     Suggest: Rename branch to include ticket
             or switch to direct method
   ```

4. **Check message format**
   ```
   Current message: "feat: add authentication"
   Extracted ticket: "PROJ-123"

   If message already has [PROJ-123]:
     Validate and pass
   Else:
     Prepend: "[PROJ-123] feat: add authentication"
   ```

5. **Validate Conventional Commits**
   ```
   Pattern: ^\[PROJ-\d+\]\s+(feat|fix|...):.+
   ```

**Valid scenarios:**
```
Branch: feature/PROJ-123-auth
User message: "feat: add login"
Result: "[PROJ-123] feat: add login" ✅

Branch: bugfix/JIRA-456-cache
User message: "[JIRA-456] fix: resolve leak"
Result: "[JIRA-456] fix: resolve leak" ✅ (already prefixed)
```

**Invalid scenarios:**
```
Branch: feature/add-auth (no ticket)
Error: ❌ Can't extract ticket from branch name
Suggestion: Use "feature/PROJ-123-auth" format

User message: "update login"
Error: ❌ Missing Conventional Commits type
Suggestion: "feat: update login" or "[PROJ-123] feat: update login"
```

---

### Ticket Method: direct

**Requirement:** Use stored `currentTicket` from policy config

**Process:**

1. **Load current ticket**
   ```json
   {
     "currentTicket": "PROJ-123"
   }
   ```

2. **If ticket not set**
   ```
   Ask: "What ticket/issue are you working on?"
   Store: currentTicket = "PROJ-123"
   ```

3. **Prepend to message**
   ```
   Current message: "feat: add authentication"
   Current ticket: "PROJ-123"

   If message has [PROJ-123]:
     Keep as-is
   Else:
     Prepend: "[PROJ-123] feat: add authentication"
   ```

4. **Validate format**
   ```
   Pattern: ^\[.+\]\s+(feat|fix|...):.+
   ```

**Valid scenarios:**
```
currentTicket: "PROJ-123"
User message: "feat: add login"
Result: "[PROJ-123] feat: add login" ✅

currentTicket: "PROJ-123"
User message: "[PROJ-123] feat: add login"
Result: "[PROJ-123] feat: add login" ✅ (no duplication)

currentTicket: not set
User message: "fix: update cache"
Ask: "What ticket?"
User: "PROJ-456"
Result: "[PROJ-456] fix: update cache" ✅
```

**Invalid scenarios:**
```
currentTicket: not set
No user response: Ask again, don't commit

User message: "add authentication"
Missing type: ❌ Reject, show format example
```

---

## Co-Authored-By Enforcement

### Always Applied (if enabled)

**Location:** Last line of commit message, after blank line

**Private Project Format:**
```
[message body]

Co-Authored-By: Claude Haiku 4.5
```

**Personal Project Format:**
```
[message body]

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>
```

### Implementation

1. **Check if already present**
   ```
   If message contains "Co-Authored-By:":
     - If format matches: ✅ Keep
     - If format wrong: Fix formatting
   Else:
     - Append to end
   ```

2. **Add blank line separator**
   ```
   Before:
     feat: add login

   After:
     feat: add login

     Co-Authored-By: Claude Haiku 4.5
   ```

3. **Never duplicate**
   ```
   If already has Co-Authored-By:
     Don't add another
     (Fix only if format is wrong)
   ```

4. **Use correct model name**
   ```
   ✅ Valid:
     - Claude Haiku 4.5
     - Claude Sonnet 4.6
     - Claude Opus 4.6

   ❌ Invalid:
     - Claude
     - AI Assistant
     - [user name]
   ```

### Validation Examples

**Private project (includeEmail: false):**
```
Input message:
"feat: add authentication

Implement user login and logout."

Output:
"feat: add authentication

Implement user login and logout.

Co-Authored-By: Claude Haiku 4.5"
```

**Personal project (includeEmail: true):**
```
Input message:
"feat: add authentication"

Output:
"feat: add authentication

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>"
```

**Already present (fix if wrong):**
```
Input:
"feat: add auth

Co-Authored-By: Claude <claude@anthropic.com>"  # Wrong format

Output:
"feat: add auth

Co-Authored-By: Claude Haiku 4.5"  # Corrected (private)
or
"feat: add auth

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>"  # Corrected (personal)
```

---

## Policy Not Found

**Scenario:** `.claude/git-policy.json` doesn't exist

**Actions:**
```
1. Check for policy file
2. If missing:
   Message: "No git policy configured"
   Options:
     a) Run git-policy-setup
     b) Apply default policies
     c) Proceed without enforcement
3. Store user choice
4. Proceed accordingly
```

**Default policies (fallback):**
```json
{
  "commitConfirmation": { "enabled": false },
  "commitMessageFormat": { "ticketMethod": "none" },
  "coAuthoredBy": { "enabled": false }
}
```

---

## Execution Order

**Policy enforcement sequence:**

```
1. Load policy file
   ↓
2. If commitConfirmation enabled:
   Ask for confirmation
   ↓ (if not confirmed, stop)
   ↓
3. Validate message format:
   - Check Conventional Commits
   - Apply ticket formatting
   - Validate final format
   ↓ (if invalid, request fix and retry)
   ↓
4. Apply Co-Authored-By:
   - Append if enabled
   - Fix if malformed
   ↓
5. Display final message
   Ask: "Proceed with commit?"
   ↓ (if yes, execute)
   ↓
6. Execute git commit (via MCP)
   ↓
7. Update policy.appliedAt timestamp
```

---

## Error Recovery

### Message Format Error

```
❌ Commit message validation failed

Current: "update login"
Issue: Missing Conventional Commits type

Valid format: "feat: update login"
or: "[PROJ-123] feat: update login"

Options:
1. Fix message and retry
2. Cancel commit
```

**Recovery:**
- User fixes message
- Retry validation
- Proceed if valid

### Ticket Extraction Error

```
❌ Can't extract ticket from branch

Branch: "feature/add-auth"
Expected: "feature/PROJ-123-auth"

Options:
1. Rename branch to include ticket
2. Switch to direct method (set ticket manually)
3. Switch to no-ticket ([NT]) method
```

**Recovery:**
- User chooses option
- Update policy if needed
- Retry commit

### Policy File Corruption

```
⚠️  Policy file exists but invalid

File: .claude/git-policy.json
Error: Invalid JSON format

Options:
1. Fix policy file manually
2. Reconfigure with git-policy-setup
3. Use defaults
```

**Recovery:**
- User corrects or reconfigures
- Retry commit
