---
title: "Refactor: Replace code generation with steward:apply:<keyword> functions"
type: refactor
status: active
date: 2026-02-19
deepened: 2026-02-19
prior: .claude-archive/plans/logical-bouncing-wolf.md (Phase 1 — npm/composer/pip/go manifest batching, done)
---

# Refactor: Replace code generation with `steward:apply:<keyword>` functions

## Enhancement Summary

**Deepened on:** 2026-02-19
**Research agents used:** architecture-strategist, pattern-recognition-specialist, code-simplicity-reviewer, performance-oracle, security-sentinel, best-practices-researcher, architecture-principles, git-history-analyzer

### Key Improvements from Research
1. **CRITICAL bug fix:** `$source` variable scoping in `steward:apply:hook` — must use `STEWARD_DRY_RUN` or pass explicitly
2. **Simplification:** Merge `helm-repo` into `helm` as single apply function (eliminates YAGNI hookable stage)
3. **Security hardening:** Add manifest field character validation to prevent TSV injection and path traversal
4. **Missing test:** `test:helm:with-values-stdin` must be updated (omitted from original plan)
5. **Helm error collection:** `helm-failed` sentinel pattern must be preserved in `steward:apply:helm`

### New Considerations Discovered
- Anchor validation list in `steward:hook` will drift from `steward:apply` — accept as documented risk
- The `$(cat)` in hook/eager/defer heredocs is an intentional trust boundary, not a bug — document it
- `$name` in eager/hook/defer filenames needs path-safe validation (`^[A-Za-z0-9_-]+$`)
- Rename local `source` variable to avoid shadowing the shell builtin

---

## Overview

Convert all remaining code-generating keywords (`key`, `src`, `deb`, `bin`, `ext`, `tar`, `zip`, `helm`) into pure data collectors that write TSV manifests. Move all execution logic into `steward:apply:<keyword>` functions. Redesign hooks to use semantic filenames. Eliminate the glob-based `for script in /tmp/steward/[0-9]-[0-9][0-9]-*.sh` dispatch in favour of an explicit call list.

## Problem Statement

Keywords currently generate shell code via heredocs with interpolated variables into numbered script files (`1-NN-internal-<stage>.sh`). This creates:

- **Shell-in-shell quoting** — variable interpolation inside heredocs is fragile and error-prone
- **Duplicated script creation** — `apt` and `deb` copy-paste identical `1-04-internal-apt-install.sh` blocks (23 lines, character-for-character identical at `steward:245-267` and `steward:293-315`)
- **`if [[ ! -f ... ]]` guards** — first-call sentinels add complexity
- **Code invisible to IDE/shellcheck** — generated `.sh` files can't be statically analysed
- **Hook fragility** — `steward:hook` greps the source for `1-NN-internal-<stage>.sh` patterns to discover ordinals; any filename change breaks hooks
- **Security: heredoc injection** — unquoted `<<-SH` delimiter causes `$name`/`$url` expansion; a value containing shell metacharacters produces broken or exploitable generated scripts (see `steward:ext` at line 443 where `${ARGS[@]}` is unquoted in generated code)

Phase 1 (committed as `feac8de`) already converted `npm`, `composer`, `pip`, `go` to manifest-based collection. This plan extends that to every remaining keyword.

### Security Improvements Over Prior Design

The manifest approach eliminates:
- Heredoc code injection for `key`, `src`, `deb`, `bin`, `tar`, `zip`, `ext` (C-1)
- Helm YAML herestring injection via `helm-cmds` (the `$values` variable could contain shell metacharacters)
- Hook anchor regex injection via `grep -oP` at `steward:728`

## Design Decisions (User-Confirmed)

| Decision | Choice | Rationale |
|---|---|---|
| Pipeline ordering | Explicit call list in `steward:apply` | Readable, no indirection, grep-able |
| Hook discovery | `steward:hook` writes named files; `steward:apply:hook` globs by stage name | No ordinal lookup needed |
| Hook file naming | `hook-{before,after}-<stage>-<ord>-<name>.sh` | Ordinal for multiple hooks on same stage |
| Dry-run | `STEWARD_DRY_RUN` global; each apply fn prints its manifest | Consistent, per-function |
| Helm values | Per-release side file `/tmp/steward/helm-values-{release}` | Avoids TSV encoding of multiline YAML |
| eager/defer | Unchanged — still `0-NN-eager-<name>.sh` / `2-NN-deferred-<name>.sh` via glob | Minimal blast radius |

### Research Insight: Simplification — Merge `helm-repo` into `helm`

The original plan had `helm-repo` and `helm` as separate hookable stages. The simplicity review identified this as YAGNI — no current test covers `hook --before helm-repo` and splitting one logical operation adds 2 hook call sites + 1 function for zero demonstrated value. **Decision: merge.** `steward:apply:helm` reads `helm-repos` first, then reads `helm-manifest`. One function, one hookable stage.

## Technical Approach

### Manifest Schemas

Each keyword writes to a TSV manifest instead of generating shell code:

| Keyword | Manifest file | TSV columns | Allowed characters | Notes |
|---|---|---|---|---|
| `key` | `key-manifest` | `name\turl` | name: `[A-Za-z0-9_.-]+`, url: `https?://[^\t\n]+` | |
| `src` (repo) | `src-manifest` | `repo\tname\trepo_url\tdist\tcomp\tsigner` | name: `[A-Za-z0-9_.-]+`, dist: `[A-Za-z0-9._-]*` | `signer` empty when `--no-key` |
| `src` (deb-url) | `src-manifest` | `deb-url\turl` | url: `https?://[^\t\n]+` | First column distinguishes mode |
| `deb` | `deb-manifest` | `url\tfile\tmod` | mod: empty/`try`/`tmp` | |
| `bin` | `bin-manifest` | `name\turl` | name: `[A-Za-z0-9_.-]+` | |
| `ext` | `ext-manifest` | `url\tshell\targs...` | shell: `[A-Za-z0-9_/.-]+` | Tab-separated args after shell |
| `tar` | `tar-manifest` | `name\tpath\turl\tkeep` | name: `[A-Za-z0-9_.-]+`, path: no `\t\n` | `keep`: `true` or empty |
| `zip` | `zip-manifest` | `name\tpath\turl\tkeep` | name: `[A-Za-z0-9_.-]+`, path: no `\t\n` | `keep`: `true` or empty |
| `helm` | `helm-manifest` | `release\tchart\tnamespace\tversion\ttimeout\tvalues_file` | release: `[A-Za-z0-9_-]+` | `values_file` points to side file |
| `apt` | `apt-packages[-try\|-tmp]` | One package per line | | **Unchanged** |
| `npm` | `npm-packages` | `dir\tpkgs...` | | **Unchanged** |
| `composer` | `composer-packages` | `dir\tpkgs...` | | **Unchanged** |
| `pip` | `pip-packages` | `dir\tpkgs...` | | **Unchanged** |
| `go` | `go-packages` | `dir\tpkgs...` | | **Unchanged** |

#### Research Insight: TSV Safety

- **Write side:** Use `printf '%s\t%s\n'` instead of literal tabs — explicit `\t` survives editor reformatting
- **Read side:** `while IFS=$'\t' read -r` with `-r` prevents backslash interpretation (already used correctly)
- **Glob protection:** Add `set -f` around loops that intentionally word-split `$pkgs` (prevents `*`/`?` in package names from glob-expanding)
- **`ext` args:** Read trailing columns into an array: `IFS=$'\t' read -r url shell args_str; read -ra args_arr <<< "${args_str//$'\t'/ }"` — then invoke as `"$shell" "${args_arr[@]}"`
- **`src` two-mode read:** Use `read -r mode rest` then conditionally `IFS=$'\t' read -r name repo_url dist comp signer <<< "$rest"` — avoids implicit column aliasing

### Execution Pipeline

`steward:apply` becomes an explicit dispatch list with three tiers:

```
Tier 0: eager (glob — unchanged)
  # User-controlled ordering via :ord — no semantic dependency between scripts
  for script in /tmp/steward/0-[0-9][0-9]-*.sh

Tier 1: pipeline (explicit function calls — system-controlled, inter-stage dependencies)
  steward:apply:prereqs
  steward:apply:hook before key       → steward:apply:key       → steward:apply:hook after key
  steward:apply:hook before src       → steward:apply:src       → steward:apply:hook after src
  steward:apply:hook before deb       → steward:apply:deb       → steward:apply:hook after deb
  steward:apply:hook before apt       → steward:apply:apt       → steward:apply:hook after apt
  steward:apply:hook before ext       → steward:apply:ext       → steward:apply:hook after ext
  steward:apply:hook before bin       → steward:apply:bin       → steward:apply:hook after bin
  steward:apply:hook before tar       → steward:apply:tar       → steward:apply:hook after tar
  steward:apply:hook before zip       → steward:apply:zip       → steward:apply:hook after zip
  steward:apply:hook before npm       → steward:apply:npm       → steward:apply:hook after npm
  steward:apply:hook before composer  → steward:apply:composer  → steward:apply:hook after composer
  steward:apply:hook before helm      → steward:apply:helm      → steward:apply:hook after helm
  steward:apply:hook before pip       → steward:apply:pip       → steward:apply:hook after pip
  steward:apply:hook before go        → steward:apply:go        → steward:apply:hook after go
  steward:apply:apt-cleanup

Tier 2: deferred (glob — unchanged)
  # User-controlled ordering via :ord
  for script in /tmp/steward/2-[0-9][0-9]-*.sh
```

Each `steward:apply:<keyword>` function:
1. Guards on manifest existence (`[[ -f /tmp/steward/<manifest> ]] || return 0`)
2. Checks `STEWARD_DRY_RUN` — prints `=== <stage> ===` + manifest content, returns
3. Reads manifest via `while IFS=$'\t' read -r ...` and executes

#### Research Insight: Dry-Run Mechanism

Set `STEWARD_DRY_RUN` as a **non-local variable** in `steward:apply` before any apply sub-function call:
```bash
[[ "$dry_run" == "true" ]] && STEWARD_DRY_RUN="true"
```
Keep a separate `local runner="source"` variable (renamed from `source` to avoid shadowing the builtin) for the eager/defer glob loops. Each `steward:apply:<keyword>` checks `STEWARD_DRY_RUN` directly — no dependency on dynamic scoping.

### Hook Redesign

**Collection phase** — `steward:hook` changes to write semantic filenames:

```bash
function steward:hook() {
    local ARGS=("$@");
    local before=; args:opt before "";
    local after=;  args:opt after "";
    local ord="00"; args:arg -o ord '^:([0-9]{2})$';
    local name=;    args:arg -o name '^[A-Za-z0-9_-]+$';  # path-safe validation

    local anchor="${before:-$after}";
    [[ -z "$anchor" ]] && echo "hook: --before or --after is required" >&2 && return 1;

    # Validate anchor against known stage names
    local known="key src deb apt ext bin tar zip npm composer helm pip go";
    [[ " $known " != *" $anchor "* ]] && echo "hook: unknown anchor '$anchor'" >&2 && return 1;

    # Deprecation hint for old anchor names
    [[ "$anchor" == *-install || "$anchor" == *-setup ]] && \
        echo "hook: anchor '$anchor' uses old naming — use '${anchor%%-*}'" >&2 && return 1;

    local dir; [[ -n "$before" ]] && dir="before" || dir="after";
    ord=$(printf '%02d' $((10#$ord)));

    cat <<-SH >> "/tmp/steward/hook-${dir}-${anchor}-${ord}-${name}.sh"
        echo; echo "--- BEGIN $name";
        $(cat)
        echo "=== END $name";
    SH
}
```

Key changes:
- **No ordinal discovery** — anchor validation uses a hardcoded known-stage list instead of grepping the source
- **Semantic filenames** — `hook-before-apt-00-pre-apt.sh` instead of `1-03-hook-pre-apt.sh`
- **`:ord` support** — for ordering multiple hooks on the same stage
- **Path-safe `$name`** — validated with `'^[A-Za-z0-9_-]+$'` to prevent path traversal
- **Deprecation hint** — old `-install`/`-setup` suffixes get a helpful error message

**Apply phase** — `steward:apply:hook` globs by direction and stage:

```bash
function steward:apply:hook() {
    local dir="$1" stage="$2"
    local runner="source"
    [[ "${STEWARD_DRY_RUN:-}" == "true" ]] && runner="cat"
    for script in /tmp/steward/hook-${dir}-${stage}-*.sh; do
        [[ -f "$script" ]] || continue
        $runner "$script" || { echo "ERROR: $script" >&2; exit 1; }
    done
}
```

#### Research Insight: `$source` Scoping Bug

The original plan used `$source` from `steward:apply`'s local scope. Bash dynamic scoping means `local source` in the caller IS visible in called functions — but only if no intervening subshell exists. This is fragile. The fix: each apply function (including `steward:apply:hook`) checks `STEWARD_DRY_RUN` directly and maintains its own `runner` variable.

### Critical Gap Resolutions

**1. Sentinel for first-call guards (zip, npm, composer, pip, go)**

The `[[ ! -f /tmp/steward/<manifest> ]]` check on the manifest file replaces the `[[ ! -f /tmp/steward/1-NN-*.sh ]]` check. This is already the pattern used by npm/composer/pip/go post-Phase 1. For `zip`, the sentinel becomes `[[ ! -f /tmp/steward/zip-manifest ]]`.

**Implementation order within `steward:zip`:** (1) check sentinel, (2) conditionally schedule unzip via `steward:apt --temp unzip`, (3) write to manifest. This matches the current order and prevents double-scheduling.

**2. `steward:deb` dual-write**

`steward:deb` writes to two manifests:
- `deb-manifest` — TSV: `url\tfile\tmod` (for curl download)
- `apt-packages[-try|-tmp]` — cached file path (for apt install, unchanged)

`steward:apply:deb` handles downloads. When `mod` field equals `try`, append `|| true` to the curl command. `steward:apply:apt` handles installation (unchanged). This preserves current two-level softness.

**3. `steward:src` two-mode handling**

The first TSV column distinguishes modes:
- `repo\tname\trepo_url\tdist\tcomp\tsigner` — writes sources.list entry
- `deb-url\turl` — downloads and installs .deb package

`steward:apply:src` reads the first column and branches using the `read -r mode rest` pattern. The deb-url mode stays in `src` (not redirected to `deb`) because it doesn't share `--try`/`--temp` semantics.

**4. Helm parallel installs + values**

`steward:helm` writes to:
- `helm-manifest` — TSV: `release\tchart\tnamespace\tversion\ttimeout\tvalues_file`
- `helm-repos` — TSV: `name\turl` (unchanged)
- `/tmp/steward/helm-values-{release}` — YAML side file (if stdin values provided)

`steward:apply:helm` does:
1. Reads `helm-repos` and runs `helm repo add` + `helm repo update`
2. Reads `helm-manifest` and backgrounds each `helm upgrade` directly
3. Uses `--values /tmp/steward/helm-values-{release}` (not stdin herestring)
4. Calls `wait`, then prints logs and checks `helm-failed`

**Error collection pattern (must be preserved):**
```bash
{ helm upgrade ... > "/tmp/steward/helm-log-${release}" 2>&1 \
    || echo "$release" >> /tmp/steward/helm-failed; } &
# ... after all releases backgrounded:
wait
for log in /tmp/steward/helm-log-*; do [[ -f "$log" ]] && cat "$log"; done
[[ -f /tmp/steward/helm-failed ]] \
    && echo "helm: failed releases: $(paste -sd, /tmp/steward/helm-failed)" >&2 \
    && return 1
```

**5. Dry-run output**

Each `steward:apply:<keyword>` prints a header + manifest content:
```
=== key ===
docker	https://download.docker.com/linux/ubuntu/gpg
```
This is declarative (what will be installed) rather than imperative (what commands run). The manifest format is more useful for verification than shell commands.

**6. `steward:init` — unchanged scope**

`steward:init` still clears `/tmp/steward` and exports env vars. The `1-00-internal-prereqs.sh` heredoc is removed — prereq logic moves to `steward:apply:prereqs`. The `rm -fR` risk when sourced is an existing issue and not in scope for this refactor.

### Hook Anchor Backward Compatibility

Old Stewardfiles using `hook --before npm-install` (with `-install` suffix) will break. The new anchors are bare stage names: `hook --before npm`. This is a **breaking change** but acceptable since steward is pre-1.0 and the anchor names were always implementation details tied to filenames. A deprecation hint emits a helpful error for old-style anchors.

## Implementation Phases

### Research Insight: Implementation Sequencing

Do each keyword + its apply function together (key → apply:key, src → apply:src, etc.) rather than all keywords then all apply functions. This prevents an intermediate state where manifests are written but nothing reads them. Phase 3+4+5 are coupled and should be a single commit.

### Phase 1+2: Convert keywords to manifest writers + write apply functions

**Per keyword, do both at once:**

For each keyword:
- Remove heredoc code generation (`cat <<-SH >> /tmp/steward/1-NN-*.sh`)
- Write TSV line to manifest file instead (using `printf '%s\t%s\n'`)
- Write the corresponding `steward:apply:<keyword>` function
- Keep the same argument parsing logic

**15 apply functions:**

| Function | Reads | Does |
|---|---|---|
| `steward:apply:prereqs` | nothing | mkdir cache, apt update if needed, install curl/gpg (preserve guard from current `steward:99-106`) |
| `steward:apply:key` | `key-manifest` | curl + gpg dearmor per key |
| `steward:apply:src` | `src-manifest` | write sources.list per repo, or curl+dpkg per deb-url (branch on first column) |
| `steward:apply:deb` | `deb-manifest` | curl download each .deb to cache (`|| true` when `mod=try`) |
| `steward:apply:apt` | `apt-packages*` | apt update + apt install (unchanged logic from current `1-04` script) |
| `steward:apply:ext` | `ext-manifest` | curl + pipe to shell per entry (args as array, quoted) |
| `steward:apply:bin` | `bin-manifest` | curl + cp to /usr/local/bin per entry |
| `steward:apply:tar` | `tar-manifest` | curl + tar + cp per entry |
| `steward:apply:zip` | `zip-manifest` | curl + unzip + cp per entry |
| `steward:apply:npm` | `npm-packages` | while read dir pkgs loop (unchanged logic) |
| `steward:apply:composer` | `composer-packages` | while read dir pkgs loop (unchanged logic) |
| `steward:apply:helm` | `helm-repos` + `helm-manifest` | repo add/update, then helm upgrade per release (backgrounded + wait + error check) |
| `steward:apply:pip` | `pip-packages` | while read dir pkgs loop (unchanged logic) |
| `steward:apply:go` | `go-packages` | while read dir pkgs loop (unchanged logic) |
| `steward:apply:apt-cleanup` | `apt-packages-tmp` | remove temp packages, clean caches (buildkit only — `grep -q buildkit /proc/1/mountinfo`) |
| `steward:apply:hook` | glob `hook-{dir}-{stage}-*.sh` | source matching hooks (checks `STEWARD_DRY_RUN` directly) |

**Special cases:**
- `steward:apt` and `steward:deb` — remove the duplicated `1-04-internal-apt-install.sh` creation block and the `1-15-internal-apt-cleanup.sh` block. `apt` already writes to manifests; just remove the script guards.
- `steward:helm` — remove `1-11-internal-helm-repo.sh` and `1-12-internal-helm-install.sh` creation. Write to `helm-manifest` TSV instead of `helm-cmds`. Write values to side file. Apply function handles repos + installs together.
- `steward:zip` — change sentinel from `1-08-internal-zip-install.sh` to `zip-manifest`

### Phase 3: Rewrite `steward:hook` + `steward:apply` + clean up `steward:init`

These are coupled — do as single commit:

**`steward:hook`:**
- Remove ordinal discovery (`grep -oP` on source file)
- Add hardcoded known-stage list for anchor validation
- Add `:ord` support for ordering multiple hooks
- Add path-safe validation on `$name`: `'^[A-Za-z0-9_-]+$'`
- Add deprecation hint for old `-install`/`-setup` suffixed anchors
- Write to `hook-{before,after}-<stage>-<ord>-<name>.sh`

**`steward:apply`:**
- Set `STEWARD_DRY_RUN` non-local before any apply call
- Rename `local source` to `local runner` (avoid shadowing builtin)
- Tier 0 glob for eager scripts (using `$runner`)
- Explicit `steward:apply:<keyword>` call list with hook interposition
- Tier 2 glob for deferred scripts (using `$runner`)
- Add comment explaining tier asymmetry (glob for user-controlled tiers, explicit for system-controlled tier)

**`steward:init`:**
- Remove `1-00-internal-prereqs.sh` heredoc (lines 94-106)
- Keep everything else (rm, mkdir, env exports, os-release)

**`steward:eager` and `steward:defer`:**
- Add path-safe validation on `$name`: `'^[A-Za-z0-9_-]+$'`

### Phase 4: Update tests

**Script file existence → manifest checks:**

| Test | Old assertion | New assertion |
|---|---|---|
| `test:tar:valid` | `[[ -f 1-07-internal-tar-install.sh ]]` | `[[ -f tar-manifest ]]` |
| `test:zip:valid` | `[[ -f 1-08-internal-zip-install.sh ]]` | `[[ -f zip-manifest ]]` |
| `test:helm:not-generated-if-unused` | `[[ ! -f 1-12-internal-helm-install.sh ]]` | `[[ ! -f helm-manifest ]]` |
| `test:npm:prereq-skipped-when-present` | `[[ ! -f 1-01-..key.. ]]` / `[[ ! -f 1-02-..src.. ]]` | `[[ ! -f key-manifest ]]` / `[[ ! -f src-manifest ]]` |

**`generated()` content → manifest field checks:**

| Test | Old `generated` call | New assertion |
|---|---|---|
| `test:tar:valid` | `generated "curl"`, `"tar xzf"`, `"mktemp -d"`, `"rm -fR"` | `grep -qP "mytool\tpath/to/bin\t.*example.com" tar-manifest` |
| `test:zip:valid` | `generated "unzip -qo"`, `"mktemp -d"`, `"rm -fR"` | `grep -qP "mytool\tpath/to/bin\t.*example.com" zip-manifest` |
| `test:bin:valid` | `generated "/usr/local/bin"` | `grep -qP "jq\t.*github.com" bin-manifest` |
| `test:src:valid-deb-url` | `generated "apt install"` | `grep -q "deb-url" src-manifest` |
| `test:ext:with-shell` | `generated "'sh'"` | `grep -qP "\tsh$" ext-manifest` |
| `test:helm:valid` | `generated "helm upgrade --install"` | `grep -qP "my-nginx\tbitnami/nginx" helm-manifest` |
| `test:helm:with-values-stdin` | `generated "--values -"` | `[[ -f /tmp/steward/helm-values-my-nginx ]]` and `grep -q "replicaCount: 3" /tmp/steward/helm-values-my-nginx` |
| `test:helm:parallel-installs` | `grep -c '&$' helm-cmds` | **Drop** — parallelism is internal to `steward:apply:helm`, not testable at collection phase |

**Hook tests — new filenames:**

| Test | Old file | New file |
|---|---|---|
| `test:hook:before-anchor` | `1-08-hook-setup-node.sh` | `hook-before-npm-00-setup-node.sh` |
| `test:hook:after-anchor` | `1-11-hook-clear-cache.sh` | `hook-after-composer-00-clear-cache.sh` |
| `test:hook:before-apt-install` | `1-03-hook-pre-apt.sh` | `hook-before-apt-00-pre-apt.sh` |
| `test:hook:after-go-install` | `1-15-hook-post-go.sh` | `hook-after-go-00-post-go.sh` |

**Hook anchor names change** — tests must use bare stage names:
- `--before npm-install` → `--before npm`
- `--after composer-install` → `--after composer`
- `--before apt-install` → `--before apt`
- `--after go-install` → `--after go`

**No changes needed for:** `apt`/`npm`/`composer`/`pip`/`go` manifest tests, `eager`/`defer` tests, `guard` tests, `on-amd64`/`on-arm64`/`in-dev` tests, CLI tests, Docker integration tests.

### Phase 5: Update `.deps/@help`

Update the SCHEDULE section — replace `internal` sub-items with the new stage names (no `-install`/`-setup` suffixes since those were implementation details). Remove `helm-repo` as a separate stage.

## Acceptance Criteria

- [x] All keyword functions write to TSV manifests, zero heredoc code generation for built-in stages
- [x] Manifest field validation prevents tab/newline injection and path traversal
- [x] `steward:apply` uses explicit function dispatch for tier 1, globs only for tier 0 (eager) and tier 2 (defer)
- [x] `STEWARD_DRY_RUN` set as non-local before any apply function call
- [x] Hooks use semantic filenames and validate against known stage list
- [x] `$name` in eager/hook/defer validated path-safe
- [x] Dry-run prints manifest content per stage
- [x] Helm error collection (`helm-failed` + post-`wait` check) preserved
- [x] All unit tests pass (`bash steward.test`)
- [x] Docker integration tests pass (apt, bin, defer, include, dockerfile)
- [x] `steward:apt`/`steward:deb` script duplication eliminated

## Verification

1. `bash steward.test` — all unit tests pass
2. Docker integration tests (if Docker available)
3. Manual dry-run: `echo 'apt curl' | ./steward --dry-run`
4. Multi-keyword dry-run with key + src + apt + bin + tar + defer
5. Hook test: `hook --before apt test <<<"echo hook"` → verify `hook-before-apt-00-test.sh`

## References

- Prior Phase 1 plan: `.claude-archive/plans/logical-bouncing-wolf.md`
- User's design decisions: `~/.claude/plans/hashed-twirling-metcalfe.md`
- Main source: `steward:1-853`
- Test suite: `steward.test:1-1327`
- Help file: `.deps/@help:1-58`
