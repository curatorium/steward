# Steward

> Declarative DSL for installing packages, in a shareable fileformat called Stewardfile.

## Installation

```bash
curl -1fsSL https://raw.githubusercontent.com/curatorium/steward/main/steward -o /usr/local/bin/steward
chmod +x /usr/local/bin/steward
```

## Usage

```bash
  steward [-t|--task <task>] [...file|url] < Stewardfile    	
  cat Stewardfile | steward [-t|--task <task>] [...file|url]	
```

| Parameter         | Description                                                                                               |
|-------------------|-----------------------------------------------------------------------------------------------------------|
| `[-f\|--force]`   | Force -- skip all guard checks (treat every guard as passed).                                             |
| `[-d\|--dry-run]` | Dry run -- read the Stewardfiles, check the syntax & parameters, display what commands would be executed. |
| `[-h\|--help]`    | Prints out the usage guide.                                                                               |



| Parameter        | Description                                    |
|------------------|------------------------------------------------|
| `[...file\|url]` | Paths or URLs to process, default: Stewardfile |

## Syntax
### `include`

Include another Stewardfile (supports local files, URLs, and GitHub shorthand)	

```bash
include <file|url>	
```

| Parameter     | Description     |
|---------------|-----------------|
| `<file\|url>` | Local path, URL |

### `guard`

Conditionally skip task if command/file/directory exists.	

```bash
guard <command>    	
guard --file <file>	
guard --dir <dir>  	
```

| Parameter      | Description                                      |
|----------------|--------------------------------------------------|
| `[-f\|--file]` | Check for file existence instead of command      |
| `[-d\|--dir]`  | Check for directory existence instead of command |

| Parameter | Description                                         |
|-----------|-----------------------------------------------------|
| `<name>`  | Command name, file path, or directory path to check |

### `key`

Add a GPG keyring for package verification	

```bash
key <name> <url>	
```

| Parameter | Description                                  |
|-----------|----------------------------------------------|
| `<name>`  | Keyring filename (without .gpg extension)    |
| `<url>`   | URL to the GPG key (ASCII-armored or binary) |

### `src`

Add an APT repository source list	

```bash
src [--no-key] <name> <repo> [dist] [...comp]	
src <url:*.deb>                              	
```

| Parameter    | Description               |
|--------------|---------------------------|
| `[--no-key]` | Skip keyring verification |

| Parameter   | Description                                                             |
|-------------|-------------------------------------------------------------------------|
| `<name>`    | Source list filename (without .list extension)                          |
| `<repo>`    | APT repository URL (e.g. "https://example.com/repo/")                   |
| `[dist]`    | Distribution codename (suite) (ex.: jammy, bookwork, $VERSION_CODENAME) |
| `[...comp]` | Component(s) (ex.: main, security, universe)                            |

### `apt`

Schedule an APT package for installation	

```bash
apt [--try|--temp] <name[=version]>	
```

| Parameter  | Description                                                         |
|------------|---------------------------------------------------------------------|
| `[--try]`  | Don't fail if package unavailable                                   |
| `[--temp]` | Temporary package, removed after all installers finish (build deps) |

| Parameter          | Description                                   |
|--------------------|-----------------------------------------------|
| `<name[=version]>` | Package name, optionally with =version suffix |

### `deb`

Schedule a .deb package for installation	

```bash
deb [--try|--temp] <url>	
```

| Parameter  | Description                                                         |
|------------|---------------------------------------------------------------------|
| `[--try]`  | Don't fail if package unavailable                                   |
| `[--temp]` | Temporary package, removed after all installers finish (build deps) |

| Parameter | Description        |
|-----------|--------------------|
| `<url>`   | URL to a .deb file |

### `bin`

Download and install a binary to /usr/local/bin	

```bash
bin <name> <url>	
```

| Parameter | Description                       |
|-----------|-----------------------------------|
| `<name>`  | Binary filename in /usr/local/bin |
| `<url>`   | URL to download the binary from   |

### `tar`

Download a tar, extract it, and install a binary from it to /usr/local/bin	

```bash
tar [--keep] <name> <path/to/bin> <url>	
```

| Parameter  | Description                               |
|------------|-------------------------------------------|
| `[--keep]` | Keep the extracted archive in /opt/<name> |

| Parameter | Description                                                   |
|-----------|---------------------------------------------------------------|
| `<name>`  | Binary filename in /usr/local/bin (and /opt/<name> if --keep) |
| `<path>`  | Path to the binary inside the archive                         |
| `<url>`   | URL to download the tar from                                  |

### `zip`

Download a zip archive, extract it, and install a binary from it to /usr/local/bin	

```bash
zip [--keep] <name> <path/to/bin> <url>	
```

| Parameter  | Description                               |
|------------|-------------------------------------------|
| `[--keep]` | Keep the extracted archive in /opt/<name> |

| Parameter | Description                                                   |
|-----------|---------------------------------------------------------------|
| `<name>`  | Binary filename in /usr/local/bin (and /opt/<name> if --keep) |
| `<path>`  | Path to the binary inside the archive                         |
| `<url>`   | URL to download the zip archive from                          |

### `ext`

Execute an external installer script from a URL	

```bash
ext <url> [shell] [...args]	
```

| Parameter   | Description                               |
|-------------|-------------------------------------------|
| `<url>`     | URL to the installer script               |
| `[shell]`   | Interpreter to use. Default: bash.        |
| `[...args]` | Additional arguments passed to the script |

### `npm`

Install npm packages (global by default, local with --dir)	

```bash
npm <name[@version]>             	
npm --dir <path> [name[@version]]	
```

| Parameter          | Description                                                                   |
|--------------------|-------------------------------------------------------------------------------|
| `[name[@version]]` | Package name, optionally with @version suffix. Without --dir: global install. |

### `composer`

Install composer packages (global by default, local with --dir)	

```bash
composer <name[@version]>             	
composer --dir <path> [name[@version]]	
```

| Parameter          | Description                                                                       |
|--------------------|-----------------------------------------------------------------------------------|
| `[name[@version]]` | Package name, optionally with @version constraint. Without --dir: global require. |

### `helm`

Install a Helm chart via `helm upgrade --install --atomic --wair --create-namespace --namespace ... --timeout ...` with safe defaults.	

```bash
helm <namespace>/<release> <chart[@version]> [repo] [--timeout <seconds>] [<<<yaml]	
```

| Parameter               | Description                                                                       |
|-------------------------|-----------------------------------------------------------------------------------|
| `<namespace>/<release>` | Namespace and release name separated by / (creates namespace if missing)          |
| `<chart[@version]>`     | Chart reference (e.g. bitnami/nginx@1.2.3). Version pinned via --version.         |
| `[repo]`                | Repository URL to add (chart prefix used as repo name, deduplicated across calls) |

### `pip`

Install pip packages (global by default, local venv with --dir)	

```bash
pip <name[@version]>             	
pip --dir <path> [name[@version]]	
```

| Parameter          | Description                                                                       |
|--------------------|-----------------------------------------------------------------------------------|
| `[name[@version]]` | Package name, optionally with @version constraint. Without --dir: global install. |

### `go`

Install Go packages (global by default, local with --dir)	

```bash
go <name[@version]>             	
go --dir <path> [name[@version]]	
```

| Parameter          | Description                                                                              |
|--------------------|------------------------------------------------------------------------------------------|
| `[name[@version]]` | Module path, optionally with @version (default: @latest). Without --dir: global install. |

### `eager`

Run shell commands before the built-in pipeline	

```bash
eager [:ord] [name] <<<"command"	
eager [:ord] [name] <<SH ... SH 	
```

| Parameter | Description                                    |
|-----------|------------------------------------------------|
| `[:ord]`  | Order of script execution (00-99). Default 00. |
| `[name]`  | Label.                                         |

### `hook`

Run shell commands before/after built-in pipeline stages.	

```bash
hook --before <stage> [:ord] [name] <<<"command"	
hook --after <stage> [:ord] [name] <<<"command" 	
```

| Parameter | Description                                              |
|-----------|----------------------------------------------------------|
| `[:ord]`  | Order among hooks on the same stage (00-99). Default 00. |
| `[name]`  | Label.                                                   |

### `defer`

Defer shell commands to run after all packages are installed	

```bash
defer [:ord] [name] <<<"command"	
defer [:ord] [name] <<SH ... SH 	
```

| Parameter | Description                                    |
|-----------|------------------------------------------------|
| `[:ord]`  | Order of script execution (00-99). Default 00. |
| `[name]`  | Label.                                         |

### `on-amd64`

Run a command only on amd64 architecture	

```bash
on-amd64 <keyword> <args...>	
```

| Parameter   | Description                                |
|-------------|--------------------------------------------|
| `<keyword>` | The steward keyword to run (e.g. deb, apt) |
| `[...args]` | Arguments for the keyword                  |

### `on-arm64`

Run a command only on arm64 architecture	

```bash
on-arm64 <keyword> <args...>	
```

| Parameter   | Description                                |
|-------------|--------------------------------------------|
| `<keyword>` | The steward keyword to run (e.g. deb, apt) |
| `[...args]` | Arguments for the keyword                  |

### `in-dev`

Run a command only in dev environment (APP_ENV=dev, APP_DEBUG=1, or DEBUG set)	

```bash
in-dev <keyword> <args...>	
```

| Parameter   | Description                                |
|-------------|--------------------------------------------|
| `<keyword>` | The steward keyword to run (e.g. deb, apt) |
| `[...args]` | Arguments for the keyword                  |

## Example Stewardfiles

### Docker

```bash
# Docker
key docker https://download.docker.com/linux/ubuntu/gpg
src docker "https://download.docker.com/linux/debian $VERSION_CODENAME stable"
apt docker-ce-cli
apt docker-compose-plugin
```

### NodeJS

```bash
# NodeJS
key nodesource https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key
src nodesource "https://deb.nodesource.com/node_20.x nodistro main"
apt nodejs

defer <<SH
  npm install --global yarn
SH
```

## License

MIT
