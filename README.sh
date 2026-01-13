#!/bin/bash
# Copyright (c) 2025 Mihai Stancu (https://github.com/curatorium)

set -Eeuo pipefail;
shopt -s inherit_errexit;
shopt -s nullglob;

STEWARD="$(dirname "$0")/steward"
BEGIN_CODE='```bash'
END_CODE='```'

# @name names
# @type function
# @desc List all names of a given type
# @usage names <type>
# @arg type  The @type to filter by (command, keyword, function)
names() {
	grep -B1 "^# @type ${1?}" "$STEWARD" | grep -oP '(?<=^# @name )\S+'
}

# @name doc
# @type function
# @desc Extract @tag value(s) for a named item
# @usage doc <name> <tag>
# @arg name  The @name of the documented item
# @arg tag   The tag to extract (desc, usage, arg, flag, etc.)
doc() {
	local name="${1?}" tag="${2?}";
	sed -n "/^# @name $name\$/,/^# @name /p" "$STEWARD" | grep "^# @$tag " | sed "s/^# @$tag //"
}

# @name flag
# @type function
# @desc Format @flag tags as markdown table rows (supports -h|--help format)
# @usage flag <name>
# @arg name  The @name of the documented item
flag() {
	doc "$1" flag | while read -r name desc; do printf "| \`%s\` | %s |\n" "${name//|/\\|}" "${desc//|/\\|}"; done
}

# @name option
# @type function
# @desc Format @option tags as markdown table rows (supports -o|--opt <val> and --opt=<val> format)
# @usage option <name>
# @arg name  The @name of the documented item
option() {
	doc "$1" option | while read -r name desc; do printf "| \`%s\` | %s |\n" "${name//|/\\|}" "${desc//|/\\|}"; done
}

# @name arg
# @type function
# @desc Format @arg tags as markdown table rows
# @usage arg <name>
# @arg name  The @name of the documented item
arg() {
	doc "$1" arg | while read -r name desc; do printf "| \`%s\` | %s |\n" "${name//|/\\|}" "${desc//|/\\|}"; done
}

# @name include
# @type function
# @desc Include contents of a file
# @usage include <file>
# @arg file  Path to file (relative to script dir)
include() {
	cat "$(dirname "$0")/${1?}"
}

# Generate README.md
cat <<-MD
	# Steward

	> Declarative DSL for installing packages, in a shareable fileformat called Stewardfile.

	## Installation

	$BEGIN_CODE
	curl -1fsSL https://raw.githubusercontent.com/curatorium/steward/main/steward -o /usr/local/bin/steward
	chmod +x /usr/local/bin/steward
	$END_CODE

	## Usage

	$BEGIN_CODE
	$(doc steward usage | sed 's/^/  /')
	$END_CODE

	$([[ -n "$(flag steward)" ]] && cat <<-xMD
		| Flag | Description |
		|------|-------------|
		$(flag steward)
	xMD
	)

	$([[ -n "$(option steward)" ]] && cat <<-xMD
		| Option | Description |
		|------|-------------|
		$(option steward)
	xMD
	)

	$([[ -n "$(arg steward)" ]] && cat <<-xMD
		| Argument | Description |
		|----------|-------------|
		$(arg steward)
	xMD
	)

	## Syntax
MD

for name in $(names keyword); do
	cat <<-MD
		### \`$name\`

		$(doc "$name" desc)

		$BEGIN_CODE
		$(doc "$name" usage)
		$END_CODE

	MD

	if [[ -n "$(doc "$name" flag)" ]]; then
		cat <<-MD
			| Flag | Description |
			|------|-------------|
			$(flag "$name")

		MD
	fi

	if [[ -n "$(doc "$name" option)" ]]; then
		cat <<-MD
			| Option | Description |
			|------|-------------|
			$(option "$name")

		MD
	fi

	if [[ -n "$(doc "$name" arg)" ]]; then
		cat <<-MD
			| Argument | Description |
			|----------|-------------|
			$(arg "$name")

		MD
	fi
done

cat <<-MD
	## Example Stewardfiles

	### Docker

	$BEGIN_CODE
	$(include examples/docker.Stewardfile)
	$END_CODE

	### NodeJS

	$BEGIN_CODE
	$(include examples/nodejs.Stewardfile)
	$END_CODE

	## License

	MIT
MD
