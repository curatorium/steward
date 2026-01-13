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

## steward:eager

Scenario      | Invocation                          | Expected                  | ✓/✗
--------------|-------------------------------------|---------------------------|----
valid         | eager setup <<<"echo hello"         | content in 000-eager-*    | ✅
custom-order  | eager :50 early <<<"x"              | 050-eager-* created       | ✅
internal-flag | eager --internal :20 hook <<<"x"    | 120-eager-* created       | ✅
no-name       | eager <<<"x"                        | content captured          | ✅

---

## steward:defer

Scenario     | Invocation                   | Expected                   | ✓/✗
-------------|------------------------------|----------------------------|----
valid        | defer setup <<<"echo hello"  | content in 200-deferred-*  | ✅
custom-order | defer :50 early <<<"x"       | 250-deferred-* created     | ✅
no-name      | defer <<<"x"                 | content captured           | ✅

---

## steward:on-amd64 / steward:on-arm64

Scenario       | Invocation                  | Expected                 | ✓/✗
---------------|-----------------------------|--------------------------|----
amd64-on-amd64 | ARCH=amd64; on-amd64 apt vim   | vim in packages       | ✅
amd64-on-arm64 | ARCH=arm64; on-amd64 apt vim   | vim NOT in packages   | ✅
arm64-on-arm64 | ARCH=arm64; on-arm64 apt vim   | vim in packages       | ✅
arm64-on-amd64 | ARCH=amd64; on-arm64 apt vim   | vim NOT in packages   | ✅

---

## steward:in-dev

Scenario       | Invocation                    | Expected              | ✓/✗
---------------|-------------------------------|-----------------------|----
app-env-dev    | APP_ENV=dev; in-dev apt vim   | vim in packages       | ✅
app-debug-1    | APP_DEBUG=1; in-dev apt vim   | vim in packages       | ✅
debug-set      | DEBUG=1; in-dev apt vim       | vim in packages       | ✅
app-env-prod   | APP_ENV=prod; in-dev apt vim  | vim NOT in packages   | ✅
env-unset      | in-dev apt vim                | vim NOT in packages   | ✅

---

## steward:include

Scenario     | Invocation             | Expected                  | ✓/✗
-------------|------------------------|---------------------------|----
local-file   | include test.sf        | included content processed| ✅
missing-file | include /nonexistent   | error                     | ✅

---

## steward:guard

Scenario        | Invocation                      | Expected                      | ✓/✗
----------------|---------------------------------|-------------------------------|----
cmd-present     | guard bash                      | exits subshell (skip)         | ✅
cmd-absent      | guard nonexistent-cmd           | continues execution           | ✅
file-present    | guard --file /tmp/exists        | exits subshell (skip)         | ✅
file-absent     | guard --file /nonexistent       | continues execution           | ✅
dir-present     | guard --dir /tmp                | exits subshell (skip)         | ✅
dir-absent      | guard --dir /nonexistent        | continues execution           | ✅
no-side-effects | guard bash (in func1); func2    | func2 still runs              | 

---

## Command Interface

Scenario      | Invocation                | Expected              | ✓/✗
--------------|---------------------------|-----------------------|----
file-args     | steward file1 file2       | both files processed  | 
pipe-cat      | cat file | steward        | stdin processed       | 
redirect-file | steward < file            | stdin processed       | 
herestring    | steward <<<"..."          | content processed     | 
process-sub   | steward < <(echo ...)     | content processed     | 
heredoc       | steward <<STEW...STEW     | content processed     | 
default-file  | steward (with Stewardfile)| Stewardfile used      | 
dry-run       | steward --dry-run         | scripts shown, not run| 
task-filter   | steward --task alpha      | only alpha runs       | 
task-unset    | steward (no --task)       | all functions run     | 


---

## Docker Integration Tests

> Running in: ubuntu:24.04

Scenario       | Invocation                   | Expected              | ✓/✗
---------------|------------------------------|-----------------------|----
apt-installs   | apt curl                     | curl works            | 
apt-try-missing| apt --try nonexistent        | exits 0               | 
bin-downloads  | bin jq https://...           | jq works              | 
defer-executes | defer <<< "echo X"           | X in output           | 
include-file   | include fixtures/test.sf     | included pkg works    | 
dockerfile-run | RUN steward (in Dockerfile)  | reads Stewardfile     | 
dockerfile-fifo| RUN ./steward (writerless FIFO) | no hang, reads Stewardfile | 


## Summary

| ✅ Pass | ❌ Fail | ⚠️ Error |
|---------|---------|----------|
| 45 | 0 | 0 |

