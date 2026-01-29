# steward Test Results

## steward:key

Scenario     | Invocation                      | Expected                  | ✓/✗
-------------|---------------------------------|---------------------------|----
valid        | key docker https://example/gpg  | URL + name in output      | ✅
missing-name | key                             | error                     | ✅
missing-url  | key docker                      | error                     | ✅

---

## steward:src

Scenario      | Invocation                              | Expected                    | ✓/✗
--------------|-----------------------------------------|-----------------------------|----
valid-full    | src docker https://repo jammy stable    | repo + dist + comp in output| ✅
valid-deb-url | src https://example.com/pkg.deb         | URL + dpkg in output        | ✅
no-key-flag   | src --no-key ppa https://repo jammy     | no signed-by in output      | ✅
missing-name  | src                                     | error                       | ✅

---

## steward:apt

Scenario     | Invocation          | Expected                 | ✓/✗
-------------|---------------------|--------------------------|----
valid        | apt vim             | vim in packages file     | ✅
versioned    | apt vim=2:8.2       | version preserved        | ✅
try-flag     | apt --try pkg       | pkg in packages? file    | ✅
missing-name | apt                 | error                    | ✅

---

## steward:deb

Scenario    | Invocation                       | Expected            | ✓/✗
------------|----------------------------------|---------------------|----
valid       | deb https://example.com/pkg.deb  | URL + dpkg in output| ✅
try-flag    | deb --try https://example/pkg.deb| success             | ✅
missing-url | deb                              | error               | ✅
invalid-url | deb /local/path.deb              | error               | ✅

---

## steward:bin

Scenario     | Invocation                  | Expected                     | ✓/✗
-------------|-----------------------------|------------------------------|----
valid        | bin jq https://example/jq   | name + URL + path in output  | ✅
missing-name | bin                         | error                        | ✅
missing-url  | bin jq                      | error                        | ✅

---

## steward:ext

Scenario    | Invocation                  | Expected        | ✓/✗
------------|-----------------------------|-----------------|----
valid       | ext https://get.docker.com  | URL in output   | ✅
with-shell  | ext https://example.com sh  | shell in output | ✅
missing-url | ext                         | error           | ✅

---

## steward:defer

Scenario     | Invocation                   | Expected                   | ✓/✗
-------------|------------------------------|----------------------------|----
valid        | defer setup <<<"echo hello"  | content in 100-deferred-*  | ✅
custom-order | defer :050 early <<<"x"      | 050-deferred-* created     | ✅
no-name      | defer <<<"x"                 | content captured           | ✅

---

## steward:amd64 / steward:arm64

Scenario       | Invocation                  | Expected              | ✓/✗
---------------|-----------------------------|-----------------------|----
amd64-on-amd64 | ARCH=amd64; amd64 apt vim   | vim in packages       | ✅
amd64-on-arm64 | ARCH=arm64; amd64 apt vim   | vim NOT in packages   | ✅
arm64-on-arm64 | ARCH=arm64; arm64 apt vim   | vim in packages       | ✅
arm64-on-amd64 | ARCH=amd64; arm64 apt vim   | vim NOT in packages   | ✅

---

## steward:include

Scenario     | Invocation             | Expected                  | ✓/✗
-------------|------------------------|---------------------------|----
local-file   | include test.sf        | included content processed| ✅
missing-file | include /nonexistent   | error                     | ✅

---

## Command Interface

Scenario      | Invocation                | Expected              | ✓/✗
--------------|---------------------------|-----------------------|----
file-args     | steward file1 file2       | both files processed  | ✅
pipe-cat      | cat file | steward        | stdin processed       | ✅
redirect-file | steward < file            | stdin processed       | ✅
herestring    | steward <<<"..."          | content processed     | ✅
process-sub   | steward < <(echo ...)     | content processed     | ✅
heredoc       | steward <<STEW...STEW     | content processed     | ✅
default-file  | steward (with Stewardfile)| Stewardfile used      | ✅
dry-run       | steward --dry-run         | scripts shown, not run| ✅


---

## Docker Integration Tests

> Running in: ubuntu:24.04

Scenario       | Invocation                   | Expected              | ✓/✗
---------------|------------------------------|-----------------------|----
apt-installs   | apt curl                     | curl works            | ❌
apt-try-missing| apt --try nonexistent        | exits 0               | ❌
bin-downloads  | bin jq https://...           | jq works              | ❌
defer-executes | defer <<< "echo X"           | X in output           | ❌
include-file   | include fixtures/test.sf     | included pkg works    | ⚠️


## Summary

| ✅ Pass | ❌ Fail | ⚠️ Error |
|---------|---------|----------|
| 38 | 4 | 1 |

