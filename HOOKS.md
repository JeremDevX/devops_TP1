# 🔒 Git Hooks Configuration

## Overview

This project uses **Husky** to enforce code quality through automated Git hooks.

## Installed Hooks

### 1️⃣ **pre-commit** - Secret Detection

**Location:** `.husky/pre-commit`

- **Purpose:** Detect hardcoded secrets before committing
- **Checks for:**
  - Stripe API keys: `sk_live_*`, `sk_test_*`
  - AWS keys: `AKIA*`
  - Other sensitive data patterns
- **Action:** ❌ Blocks commit if secrets are detected

**Example:**

```bash
git add config/secrets.env
git commit -m "fix: update config"
# ❌ Pre-commit hook blocked - secret detected in config/secrets.env
```

### 2️⃣ **commit-msg** - Commit Message Validation

**Location:** `.husky/commit-msg`

- **Purpose:** Enforce Conventional Commits format
- **Tool:** Commitlint
- **Rules:** Only these commit types are allowed:
  - `feat:` - New feature
  - `fix:` - Bug fix
  - `chore:` - Maintenance
  - `docs:`, `style:`, `refactor:`, `test:`, `ci:`, `build:`, `perf:`, `revert:`
- **Action:** ❌ Rejects commits with invalid messages

**Example:**

```bash
git commit -m "lol: test"
# ❌ Error: type must be one of [feat, fix, chore, ...]

git commit -m "feat: add new feature"
# ✅ Accepted
```

### 3️⃣ **pre-push** - Build Verification

**Location:** `.husky/pre-push`

- **Purpose:** Ensure projects build successfully before pushing
- **Checks:**
  - Frontend build (`npm run build` in frontend/)
  - Backend build (if applicable)
- **Action:** ❌ Blocks push if build fails

**Example:**

```bash
git push origin feature/my-feature
# → Builds frontend
# → Builds backend
# → If successful: ✅ Push allowed
# → If failed: ❌ Push blocked
```

## Configuration Files

### `commitlint.config.js`

Configures Commitlint rules:

```js
module.exports = { extends: ["@commitlint/config-conventional"] };
```

### `.gitleaks.toml`

Gitleaks configuration for advanced secret detection patterns.

## Bypassing Hooks (Emergency Only ⚠️)

If absolutely necessary:

```bash
git commit --no-verify   # Skip pre-commit and commit-msg hooks
git push --no-verify    # Skip pre-push hook
```

**⚠️ Use only in emergencies - it defeats the purpose of automated quality checks.**

## Troubleshooting

### Commit blocked due to false positive secret detection

Edit `.husky/pre-commit` to refine patterns or use `--no-verify` if confident.

### Build fails in pre-push

Ensure `npm run build` works locally before pushing:

```bash
cd frontend && npm run build
cd backend && npm run build  # if applicable
```

### Commitlint rejecting valid messages

Run `npx commitlint --help` or check `commitlint.config.js` rules.

## For Developers

When setting up the project:

```bash
git clone https://github.com/LargeGaultier/CloudNativeApplicationCurse
cd CloudNativeApplicationCurse
npm install
npm run prepare  # Installs hooks
```

Hooks are automatically triggered on:

- ✅ `git commit` - pre-commit and commit-msg hooks
- ✅ `git push` - pre-push hook

No additional configuration needed!
