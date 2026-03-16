# Steward

Declarative bash DSL for installing packages on Ubuntu/Debian systems, using a shareable file format called `Stewardfile`. Single-file bash script (~960 lines), MIT licensed, by Mihai Stancu / curatorium.

## What It Does

Steward reads one or more Stewardfiles (which are valid bash), collects package declarations into manifests under `/tmp/steward/`, then executes them in a fixed pipeline order. It is designed primarily for Docker image builds and system provisioning.

## Architecture

### Single Entry Point

`steward` is the entire application -- one bash script. No compilation, no build step for dev. The release workflow (`bash-import pack`) bundles dependencies into `.dist/steward` for distribution.

### Two-Phase Execution

1. **Collection phase**: Stewardfile tasks are sourced inside nested subshells. Each DSL keyword (`apt`, `key`, `src`, `bin`, etc.) appends to TSV manifest files under `/tmp/steward/`.
2. **Apply phase** (`steward:apply`): Executes all collected manifests in a fixed order: prereqs -> eager -> key -> src -> deb -> apt -> ext -> bin -> tar -> zip -> npm -> composer -> helm -> pip -> go -> defer -> clean-up. Each stage has optional before/after hooks.

### Naming Conventions

- `steward:keyword()` -- Public DSL keywords callable from Stewardfiles (e.g. `steward:apt`, `steward:guard`).
- `steward::apply:stage()` -- Internal apply functions that process collected manifests.
- `steward::prereq:stage()` -- Auto-installs prerequisites for a keyword if its manifest exists but the tool is missing.
- `steward::init()`, `steward::dry-run()` -- Internal helpers (double-colon = private).

### Dependencies

External bash libraries from `curatorium/bash-import` (vendored in `.deps/`):
- `bash-args` -- Argument parsing (`args:flag`, `args:opt`, `args:arg`).
- `bash-import/namespace.sh` -- Namespace aliasing (`namespace:use "steward:[^:]*" as ""`), which is what allows Stewardfiles to write `apt vim` instead of `steward:apt vim`.
- `bash-import/strict.sh` -- `set -Eeuo pipefail` and friends.
- `bash-import/trace.sh` -- Optional execution tracing.

### Subshell Isolation

The script uses nested subshells deliberately:
- Outer subshell: isolates aliases/functions from caller scope.
- Per-file subshell: isolates each Stewardfile's task definitions.
- Per-task subshell: allows `guard` to `exit 0` to skip a task without killing the pipeline.

## File Map

| File | Purpose |
|---|---|
| `steward` | Main script. All keywords, collectors, apply functions, orchestrator. |
| `Stewardfile` | The project's own Stewardfile (dev tools: git, shellcheck, docker). |
| `steward.test` | Unit tests (~134 tests). Uses `bash-test` framework. Sources `steward` and tests each keyword's collector function. |
| `steward.test.md` | Auto-generated test results report (checked by pre-commit hook). |
| `steward.comp` | Bash completion script for the `steward` command. |
| `steward.tmLanguage` | TextMate grammar for Stewardfile syntax highlighting. |
| `examples/*.Stewardfile` | Example Stewardfiles (Docker, NodeJS). |
| `docker-compose.yml` | Sandbox container for manual testing (`ubuntu:24.04`). |
| `.deps/` | Vendored bash-import dependencies (gitignored vendor dir, fetched by `bash-import`). |
| `.deps/@readme` | Script that generates `README.md` from docblock annotations in `steward`. |
| `.deps/@help` | Script that generates `--help` output from docblock annotations. |
| `.githooks/pre-commit` | Runs shellcheck, tests, and checks README/report freshness. |
| `.github/workflows/release.yml` | Tag-triggered: packs, tests in Docker, creates GH release. |

## DSL Keywords (Stewardfile Syntax)

All keywords are bash functions namespaced as `steward:*`. The namespace aliasing makes them callable without the prefix in Stewardfiles.

**Package types**: `apt`, `deb`, `bin`, `tar`, `zip`, `ext`, `npm`, `composer`, `pip`, `go`, `helm`
**Repository setup**: `key`, `src`
**Flow control**: `guard`, `include`, `eager`, `hook`, `defer`
**Conditionals**: `on-amd64`, `on-arm64`, `in-dev`

## Testing

```bash
# Run tests (requires bash-test from curatorium/bash-import)
bash-test steward.test

# Run pre-commit checks (shellcheck + tests + README freshness)
.githooks/pre-commit

# Manual sandbox testing
docker compose up -d
docker compose exec sandbox bash
# then: ./steward
```

Tests are pure unit tests on the collector functions -- they verify manifest files are written correctly under `/tmp/steward/`. Integration tests run in a Docker container and verify real installs.

## Build / Release

- `bash-import pack steward -o .dist/steward` -- Bundles dependencies inline into a single portable script.
- Release is triggered by pushing a `v*` tag. The GitHub Actions workflow packs, runs checks in Docker, and creates a GitHub release with `.dist/steward` as the artifact.

## Environment Variables

- `ARCH` -- Set automatically from `dpkg --print-architecture`.
- `VERSION_CODENAME`, `ID` -- From `/etc/os-release`.
- `PHPVS` -- Optional PHP version suffix for composer prereq (e.g. `8.2`).
- `NODEVS` -- Optional Node.js major version for npm prereq (e.g. `20`).
- `APP_ENV`, `APP_DEBUG`, `DEBUG` -- Checked by `in-dev` conditional.

## Key Design Decisions

- **Stewardfiles are valid bash**. The DSL is syntactic sugar via aliases and namespace imports, not a custom parser.
- **Collect-then-apply** pattern deduplicates and sorts manifests before execution. This means keyword order in a Stewardfile does not matter (except within `eager`/`defer` ordering).
- **Guard uses `exit 0` not `return`** because each task runs in its own subshell. This is intentional and documented.
- **Temporary packages** (`--temp` flag) are auto-removed during clean-up, but only inside Docker BuildKit builds (detected via `/proc/1/mountinfo`).
- **Cache-aware clean-up**: `/var/cache/apt/archives`, `/var/lib/apt/lists`, and `/var/cache/steward` are only cleaned if they are not bind-mounted (preserves Docker BuildKit cache mounts).
