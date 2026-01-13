# Steward

> Declarative DSL for installing packages, in a shareable fileformat called Stewardfile.

## Installation

```bash
curl -1fsSL https://raw.githubusercontent.com/curatorium/steward/main/steward -o /usr/local/bin/steward
chmod +x /usr/local/bin/steward
```

## Usage

```bash
  steward [...file|url] < Stewardfile
  cat Stewardfile | steward [...file|url]
```

| Flag | Description |
|------|-------------|
| `[-h\|--help]` | Prints out the usage guide. |



| Argument | Description |
|----------|-------------|
| `[...file\|url]` | Paths or URLs to process, default: Stewardfile |

## Syntax
### `:include`

Include another Stewardfile (supports local files, URLs, and GitHub shorthand)

```bash
:include <file|url>
```

| Argument | Description |
|----------|-------------|
| `<file\|url>` | Local path, URL |

### `:key`

Add a GPG keyring for package verification

```bash
:key <name> <url>
```

| Argument | Description |
|----------|-------------|
| `<name>` | Keyring filename (without .gpg extension) |
| `<url>` | URL to the GPG key (ASCII-armored or binary) |

### `:src`

Add an APT repository source list

```bash
:src [--no-key] <name> <repo> [dist] [...comp]
:src <url:*.deb>
```

| Flag | Description |
|------|-------------|
| `[--no-key]` | Skip keyring verification |

| Argument | Description |
|----------|-------------|
| `<name>` | Source list filename (without .list extension) |
| `<repo>` | APT repository URL (e.g. "https://example.com/repo/") |
| `[dist]` | Distribution codename (suite) (ex.: jammy, bookwork, $VERSION_CODENAME) |
| `[...comp]` | Component(s) (ex.: main, security, universe) |

### `:apt`

Schedule an APT package for installation

```bash
:apt [--try] <name[=version]>
```

| Flag | Description |
|------|-------------|
| `[--try]` | Don't fail if package unavailable |

| Argument | Description |
|----------|-------------|
| `<name[=version]>` | Package name, optionally with =version suffix |

### `:deb`

Schedule a .deb package for installation

```bash
:deb [--try|--now] <url>
```

| Flag | Description |
|------|-------------|
| `[--try]` | Don't fail if package unavailable |
| `[--now]` | Install immediately (for bootstrapping sources) |

| Argument | Description |
|----------|-------------|
| `<url>` | URL to a .deb file |

### `:bin`

Download and install a binary to /usr/local/bin

```bash
:bin <name> <url>
```

| Argument | Description |
|----------|-------------|
| `<name>` | Binary filename in /usr/local/bin |
| `<url>` | URL to download the binary from |

### `:ext`

Execute an external installer script from a URL

```bash
:ext <url> [shell] [...args]
```

| Argument | Description |
|----------|-------------|
| `<url>` | URL to the installer script |
| `<shell>` | Interpreter to use (default: bash) |
| `[...args]` | Additional arguments passed to the script |

### `:defer`

Defer shell commands to run after all packages are installed

```bash
:defer [name] <<<"command"
:defer [name] <<SH ... SH
```

| Argument | Description |
|----------|-------------|
| `<name>` | Optional label for the deferred block (for debugging) |

### `:amd64`

Run a command only on amd64 architecture

```bash
:amd64 <command> <args...>
```

| Argument | Description |
|----------|-------------|
| `<keyword>` | The steward keyword to run (e.g. :deb, :apt) |
| `[...args]` | Arguments for the keyword |

### `:arm64`

Run a command only on arm64 architecture

```bash
:arm64 <keyword> <args...>
```

| Argument | Description |
|----------|-------------|
| `<keyword>` | The steward command to run (e.g. :deb, :apt) |
| `[...args]` | Arguments for the keyword |

### `:apply`

Execute all queued operations in order (auto-invoked unless steward is importd/sourced)

```bash

```

## Example Stewardfiles

### Docker

```bash
# Docker
:key docker https://download.docker.com/linux/ubuntu/gpg
:src docker "https://download.docker.com/linux/debian $VERSION_CODENAME stable"
:apt docker-ce-cli
:apt docker-compose-plugin
```

### NodeJS

```bash
# NodeJS
:key nodesource https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key
:src nodesource "https://deb.nodesource.com/node_20.x nodistro main"
:apt nodejs

:defer <<SH
  npm install --global yarn
SH
```

## License

MIT
