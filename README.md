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

| Flag | Description |
|------|-------------|
| Parameter         | Description                                                                                               |
|-------------------|-----------------------------------------------------------------------------------------------------------|
| `[-d\|--dry-run]` | Dry run -- read the Stewardfiles, check the syntax & parameters, display what commands would be executed. |
| `[-h\|--help]`    | Prints out the usage guide.                                                                               |



| Argument | Description |
|----------|-------------|
| Parameter        | Description                                    |
|------------------|------------------------------------------------|
| `[...file\|url]` | Paths or URLs to process, default: Stewardfile |

## Syntax
### `include`

Include another Stewardfile (supports local files, URLs, and GitHub shorthand)	

```bash
include <file|url>	
```

| Argument | Description |
|----------|-------------|
| Parameter     | Description     |
|---------------|-----------------|
| `<file\|url>` | Local path, URL |

### `guard`

Skip the current function if a condition is already met (command exists, file exists, or directory exists).	
Must be called inside a Stewardfile function (which runs in a subshell). Uses exit 0 to bail out.          	

```bash
guard <command>    	
guard --file <file>	
guard --dir <dir>  	
```

| Flag | Description |
|------|-------------|
| Parameter      | Description                                      |
|----------------|--------------------------------------------------|
| `[-f\|--file]` | Check for file existence instead of command      |
| `[-d\|--dir]`  | Check for directory existence instead of command |

| Argument | Description |
|----------|-------------|
| Parameter | Description                                         |
|-----------|-----------------------------------------------------|
| `<name>`  | Command name, file path, or directory path to check |

### `key`

Add a GPG keyring for package verification	

```bash
key <name> <url>	
```

| Argument | Description |
|----------|-------------|
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

| Flag | Description |
|------|-------------|
| Parameter    | Description               |
|--------------|---------------------------|
| `[--no-key]` | Skip keyring verification |

| Argument | Description |
|----------|-------------|
| Parameter   | Description                                                             |
|-------------|-------------------------------------------------------------------------|
| `<name>`    | Source list filename (without .list extension)                          |
| `<repo>`    | APT repository URL (e.g. "https://example.com/repo/")                   |
| `[dist]`    | Distribution codename (suite) (ex.: jammy, bookwork, $VERSION_CODENAME) |
| `[...comp]` | Component(s) (ex.: main, security, universe)                            |

### `apt`

Schedule an APT package for installation	

```bash
apt [--try] [--temp] <name[=version]>	
```

| Flag | Description |
|------|-------------|
| Parameter  | Description                                                         |
|------------|---------------------------------------------------------------------|
| `[--try]`  | Don't fail if package unavailable                                   |
| `[--temp]` | Temporary package, removed after all installers finish (build deps) |

| Argument | Description |
|----------|-------------|
| Parameter          | Description                                   |
|--------------------|-----------------------------------------------|
| `<name[=version]>` | Package name, optionally with =version suffix |

### `deb`

Schedule a .deb package for installation	

```bash
deb [--try] <url>	
```

| Flag | Description |
|------|-------------|
| Parameter | Description                       |
|-----------|-----------------------------------|
| `[--try]` | Don't fail if package unavailable |

| Argument | Description |
|----------|-------------|
| Parameter | Description        |
|-----------|--------------------|
| `<url>`   | URL to a .deb file |

### `bin`

Download and install a binary to /usr/local/bin	

```bash
bin <name> <url>	
```

| Argument | Description |
|----------|-------------|
| Parameter | Description                       |
|-----------|-----------------------------------|
| `<name>`  | Binary filename in /usr/local/bin |
| `<url>`   | URL to download the binary from   |

### `ext`

Execute an external installer script from a URL	

```bash
ext <url> [shell] [...args]	
```

| Argument | Description |
|----------|-------------|
| Parameter   | Description                               |
|-------------|-------------------------------------------|
| `<url>`     | URL to the installer script               |
| `[shell]`   | Interpreter to use. Default: bash.        |
| `[...args]` | Additional arguments passed to the script |

### `eager`

Run shell commands before the built-in pipeline (eager scripts: 0-99)	

```bash
eager [:ord] [name] <<<"command"           	
eager --internal [:ord] [name] <<<"command"	
eager [:ord] [name] <<SH ... SH            	
```

| Flag | Description |
|------|-------------|
| Parameter                                                                         | Description |
|-----------------------------------------------------------------------------------|-------------|
| `[--internal]	Shift base from 000 to 100 (injection into the built-in pipeline).` |             |

| Argument | Description |
|----------|-------------|
| Parameter                                                | Description |
|----------------------------------------------------------|-------------|
| `[:ord]		Order of script execution (00-99). Default 00.` |             |
| `[name]		Label.`                                         |             |

### `defer`

Defer shell commands to run after all packages are installed (deferred scripts: 0-99)	

```bash
defer [:ord] [name] <<<"command"	
defer [:ord] [name] <<SH ... SH 	
```

| Argument | Description |
|----------|-------------|
| Parameter                                               | Description |
|---------------------------------------------------------|-------------|
| `[:ord]	Order of script execution (00-99). Default 00.` |             |
| `[name]	Label`                                          |             |

### `on-amd64`

Run a command only on amd64 architecture	

```bash
on-amd64 <keyword> <args...>	
```

| Argument | Description |
|----------|-------------|
| Parameter   | Description                                |
|-------------|--------------------------------------------|
| `<keyword>` | The steward keyword to run (e.g. deb, apt) |
| `[...args]` | Arguments for the keyword                  |

### `on-arm64`

Run a command only on arm64 architecture	

```bash
on-arm64 <keyword> <args...>	
```

| Argument | Description |
|----------|-------------|
| Parameter   | Description                                |
|-------------|--------------------------------------------|
| `<keyword>` | The steward keyword to run (e.g. deb, apt) |
| `[...args]` | Arguments for the keyword                  |

### `in-dev`

Run a command only in dev environment (APP_ENV=dev, APP_DEBUG=1, or DEBUG set)	

```bash
in-dev <keyword> <args...>	
```

| Argument | Description |
|----------|-------------|
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
