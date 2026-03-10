---
name: punch
description: (lefthook) Analyze repo and interactively set up lefthook guardrails
argument-hint: "[focus area: lint, format, test, all]"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - AskUserQuestion
  - Write
  - Edit
---

Analyze the current repository, detect its tech stack and existing tools, then interactively set up lefthook with git hooks that enforce code quality guardrails.

## Step 1: Check prerequisites

Check if lefthook is installed:

```bash
command -v lefthook && lefthook version
```

If not installed, tell the user how to install it for their platform:
- **macOS**: `brew install lefthook`
- **npm**: `npm install lefthook --save-dev`
- **go**: `go install github.com/evilmartians/lefthook/v2@latest`
- **pip**: `pipx install lefthook`

Do NOT proceed until lefthook is available.

## Step 2: Check for existing config

Look for existing lefthook config files:

Use the Glob tool to check for existing config files matching patterns: `lefthook.yml`, `lefthook.yaml`, `.lefthook.yml`, `.lefthook.yaml`, `lefthook.toml`, `lefthook.json`, `.config/lefthook.yml`.

If a config exists, read it and ask the user:
- **Enhance** — add to the existing config
- **Replace** — start fresh
- **Cancel** — leave it alone

## Step 3: Detect project stack

Scan the repo to identify:

### Package managers and languages

| File | Stack |
|------|-------|
| `package.json` | Node.js / JavaScript / TypeScript |
| `tsconfig.json` | TypeScript |
| `Gemfile` | Ruby |
| `go.mod` | Go |
| `pyproject.toml` or `requirements.txt` or `setup.py` | Python |
| `Cargo.toml` | Rust |
| `composer.json` | PHP |
| `mix.exs` | Elixir |
| `build.gradle` or `pom.xml` | Java/Kotlin |
| `*.swift` or `Package.swift` | Swift |
| `Makefile` | Make-based build |

### Linters and formatters (read package.json deps, Gemfile, etc.)

| Tool | Detection |
|------|-----------|
| ESLint | `eslint` in package.json deps/devDeps, or `.eslintrc*` |
| Prettier | `prettier` in deps, or `.prettierrc*` |
| Biome | `@biomejs/biome` in deps, or `biome.json` |
| RuboCop | `rubocop` in Gemfile, or `.rubocop.yml` |
| Standard (Ruby) | `standard` in Gemfile |
| Ruff | `ruff` in pyproject.toml or `ruff.toml` |
| Black | `black` in pyproject.toml deps |
| Flake8 | `flake8` in deps or `.flake8` |
| mypy | `mypy` in deps or `mypy.ini` |
| golangci-lint | `.golangci.yml` or `.golangci.yaml` |
| gofmt/goimports | Always available if Go detected |
| Clippy | Always available if Rust detected |
| rustfmt | Always available if Rust detected |
| SwiftLint | `.swiftlint.yml` or `swiftlint` in deps |
| PHP CS Fixer | `php-cs-fixer` in composer.json |
| Credo | `credo` in mix.exs |
| mix format | Always available if Elixir detected |
| markdownlint | `markdownlint` in deps or `.markdownlint*` |
| shellcheck | `shellcheck` available on PATH |
| actionlint | `.github/workflows/` directory exists |

### Test runners

| Tool | Detection |
|------|-----------|
| Jest | `jest` in deps |
| Vitest | `vitest` in deps |
| Mocha | `mocha` in deps |
| pytest | `pytest` in deps or `pytest.ini` or `conftest.py` |
| RSpec | `rspec` in Gemfile or `spec/` directory |
| Minitest | `minitest` in Gemfile or `test/` directory |
| Go test | `go.mod` exists |
| cargo test | `Cargo.toml` exists |
| mix test | `mix.exs` exists |
| PHPUnit | `phpunit` in composer.json |

### Type checkers

| Tool | Detection |
|------|-----------|
| TypeScript (tsc) | `typescript` in deps |
| mypy | `mypy` in deps |
| Sorbet | `sorbet` in Gemfile |

### Build tools

Look for build scripts in package.json (`build`, `compile`), Makefiles, or language-specific build commands.

### CI config

Check `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/config.yml` for existing CI checks that should be mirrored locally.

## Step 4: Build recommendations

Based on detected tools, prepare hook recommendations in these categories:

### pre-commit hooks (run on every commit)
- **Linting**: Run detected linters on staged files
- **Formatting**: Run detected formatters (with `stage_fixed: true` to auto-stage fixes)
- **Type checking**: Run type checkers if detected

### commit-msg hooks
- **Conventional commits**: Validate commit message format if the project uses conventional commits (check for `commitlint`, `@commitlint/cli`, or `.commitlintrc*`)

### pre-push hooks (run before push)
- **Tests**: Run detected test suites
- **Build**: Run build if build script exists
- **Type checking**: Full type check (if too slow for pre-commit)

### Custom groups (run manually with `lefthook run <name>`)
- **fix**: Auto-fix linting and formatting issues

## Step 5: Interactive selection

Present the recommendations to the user organized by hook type. For each recommendation show:
- What it does
- The command that will run
- Which files it targets (glob pattern)

Use AskUserQuestion to let the user choose. Present as a checklist-style selection:

```
I found the following tools in your repo. Pick which hooks you want:

PRE-COMMIT (runs on every commit):
  [1] ESLint — lint staged .js/.ts files
  [2] Prettier — format staged files (auto-stage fixes)
  [3] TypeScript — type-check

COMMIT-MSG:
  [4] Conventional commits — enforce commit message format

PRE-PUSH (runs before push):
  [5] Jest — run test suite
  [6] Build — run `npm run build`

Type the numbers you want (e.g., "1,2,4,5" or "all"):
```

If the user passed a focus area argument (lint, format, test, all), pre-select those categories.

## Step 6: Generate lefthook.yml

Build the config using the user's selections. Follow these rules:

### General structure
```yaml
pre-commit:
  parallel: true
  jobs:
    - name: <descriptive name>
      run: <command> {staged_files}
      glob: "<pattern>"
```

### Key patterns by tool

**JavaScript/TypeScript linting:**
```yaml
- name: eslint
  run: npx eslint --fix {staged_files}
  glob: "*.{js,jsx,ts,tsx}"
  stage_fixed: true
```

**Prettier formatting:**
```yaml
- name: prettier
  run: npx prettier --write {staged_files}
  glob: "*.{js,jsx,ts,tsx,css,scss,json,md,yaml,yml}"
  stage_fixed: true
```

**Biome (lint + format):**
```yaml
- name: biome
  run: npx biome check --write {staged_files}
  glob: "*.{js,jsx,ts,tsx,json}"
  stage_fixed: true
```

**Ruby linting:**
```yaml
- name: rubocop
  run: bundle exec rubocop --force-exclusion --server {staged_files}
  glob: "*.rb"
```

**Ruby formatting (with auto-correct):**
```yaml
- name: rubocop-fix
  run: bundle exec rubocop -A --force-exclusion --server {staged_files}
  glob: "*.rb"
  stage_fixed: true
```

**Python linting:**
```yaml
- name: ruff-check
  run: ruff check --fix {staged_files}
  glob: "*.py"
  stage_fixed: true
```

**Python formatting:**
```yaml
- name: ruff-format
  run: ruff format {staged_files}
  glob: "*.py"
  stage_fixed: true
```

**Go linting:**
```yaml
- name: golangci-lint
  run: golangci-lint run --new-from-rev=HEAD
  glob: "*.go"
```

**Go formatting:**
```yaml
- name: goimports
  run: goimports -w {staged_files}
  glob: "*.go"
  stage_fixed: true
```

**Rust:**
```yaml
- name: clippy
  run: cargo clippy -- -D warnings
  glob: "*.rs"

- name: rustfmt
  run: rustfmt {staged_files}
  glob: "*.rs"
  stage_fixed: true
```

**Elixir:**
```yaml
- name: mix-format
  run: mix format {staged_files}
  glob: "*.{ex,exs}"
  stage_fixed: true
```

**Conventional commits:**
```yaml
commit-msg:
  jobs:
    - name: conventional-commit
      run: 'grep -qE "^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .+" {1} || (echo "Commit message must follow conventional commits format" && exit 1)'
```

If commitlint is installed:
```yaml
commit-msg:
  jobs:
    - name: commitlint
      run: npx commitlint --edit {1}
```

**Tests (pre-push):**
```yaml
pre-push:
  jobs:
    - name: test
      run: npm test
```

Adjust the test command based on detected runner (pytest, rspec, go test, cargo test, mix test, etc.).

### Output configuration

Add sensible output defaults:
```yaml
output:
  - meta
  - summary
  - failure
```

## Step 7: Write config and install

1. Write the generated `lefthook.yml` to the repo root using the Write tool
2. Run `lefthook install` to activate the hooks
3. Show the user what was created with a summary

```
Done! lefthook.yml created with:
  - pre-commit: eslint, prettier (auto-fix + stage)
  - commit-msg: conventional commits
  - pre-push: jest tests

Hooks are installed. They'll run automatically on your next commit/push.

Tips:
  - Skip hooks once: LEFTHOOK=0 git commit ...
  - Run manually: lefthook run pre-commit
  - Local overrides: create lefthook-local.yml
  - Add to .gitignore: lefthook-local.yml
```

## Step 8: Offer extras

After setup, ask if the user wants any of these:

- **Add `lefthook-local.yml` to `.gitignore`** — so devs can customize locally
- **Add a `fix` group** — manual fixer that auto-corrects all files (not just staged)
- **Add lefthook install to CI** — ensure hooks stay in sync
- **Commit the config** — commit lefthook.yml now
