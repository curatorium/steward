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
try-flag     | apt --try pkg       | pkg in packages-try file | ✅
missing-name | apt                 | error                    | ✅

---

## steward:deb

Scenario    | Invocation                       | Expected            | ✓/✗
------------|----------------------------------|---------------------|----
valid       | deb https://example.com/pkg.deb      | URL in download + path in packages     | ✅
try-flag    | deb --try https://example/pkg.deb    | URL in download + path in packages-try | ✅
temp-flag   | deb --temp https://example/pkg.deb   | URL in download + path in packages-tmp | ✅
missing-url | deb                                  | error                                  | ✅
invalid-url | deb /local/path.deb                  | error                                  | ✅

---

## steward:bin

Scenario     | Invocation                  | Expected                     | ✓/✗
-------------|-----------------------------|------------------------------|----
valid        | bin jq https://example/jq   | name + URL + path in output  | ✅
missing-name | bin                         | error                        | ✅
missing-url  | bin jq                      | error                        | ✅

---

## steward:tar

Scenario       | Invocation                                | Expected                       | ✓/✗
---------------|-------------------------------------------|--------------------------------|----
valid          | tar mytool path/bin https://url.tgz   | tar + bin + cleanup in output  | ✅
keep-flag      | tar --keep mytool path/bin https://..  | /opt/mytool created            | ✅
no-keep        | tar mytool path/bin https://url.tgz   | no /opt/mytool                 | ✅
missing-name   | tar                                   | error                          | ✅
missing-path   | tar mytool                            | error                          | ✅
missing-url    | tar mytool path/bin                   | error                          | ✅

---

## steward:zip

Scenario       | Invocation                                | Expected                       | ✓/✗
---------------|-------------------------------------------|--------------------------------|----
valid          | zip mytool path/bin https://url.zip   | unzip + bin + cleanup in output| ✅
keep-flag      | zip --keep mytool path/bin https://..  | /opt/mytool created            | ✅
no-keep        | zip mytool path/bin https://url.zip   | no /opt/mytool                 | ✅
missing-name   | zip                                   | error                          | ✅
missing-path   | zip mytool                            | error                          | ✅
missing-url    | zip mytool path/bin                   | error                          | ✅

---

## steward:ext

Scenario    | Invocation                  | Expected        | ✓/✗
------------|-----------------------------|-----------------|----
valid       | ext https://get.docker.com  | URL in output   | ✅
with-shell  | ext https://example.com sh  | shell in output | ✅
missing-url | ext                         | error           | ✅

---

## steward:npm

Scenario      | Invocation          | Expected                  | ✓/✗
--------------|---------------------|---------------------------|----
valid         | npm yarn            | yarn in manifest          | ✅
versioned     | npm yarn@1.22.0     | version preserved         | ✅
batched       | npm a; npm b        | 2 entries in manifest     | ✅
unused        | (no npm calls)      | no manifest generated     | ✅
prereq-skip   | npm x (npm exists)  | no prereqs generated      | ✅
local-dir     | npm --dir /app      | cd + npm install          | ✅
local-dir+pkg | npm --dir /app expr | cd + npm install expr     | ✅
missing-name  | npm                 | error                     | ✅

---

## steward:composer

Scenario      | Invocation                     | Expected                    | ✓/✗
--------------|--------------------------------|-----------------------------|----
valid         | composer laravel/installer     | name in manifest + prereqs  | ✅
versioned     | composer laravel/installer@^4  | version preserved           | ✅
batched       | composer a; composer b         | 2 entries in manifest       | ✅
unused        | (no composer calls)            | no manifest generated       | ✅
local-dir     | composer --dir /app            | cd + composer install       | ✅
local-dir+pkg | composer --dir /app pkg        | cd + composer require pkg   | ✅
missing-name  | composer                       | error                       | ✅

---

## steward:helm

Scenario        | Invocation                              | Expected                     | ✓/✗
----------------|-----------------------------------------|------------------------------|----
valid           | helm my-nginx bitnami/nginx             | upgrade --install + defaults | ✅
namespace       | helm prod/my-nginx bitnami/nginx        | --namespace prod             | ✅
version         | helm my-nginx bitnami/nginx@1.2.3       | --version 1.2.3              | ✅
timeout         | helm my-nginx chart --timeout 120       | --timeout 120s               | ✅
values-stdin    | helm my-nginx chart <<< "key: val"      | --values - with yaml         | ✅
with-repo       | helm my-nginx bitnami/nginx https://... | repo in helm-repos manifest  | ✅
repo-dedup      | helm a chart repo; helm b chart repo    | single repo entry            | ✅
guard-once      | helm a x; helm b y                      | both entries in manifest     | ✅
unused          | (no helm calls)                         | no manifest generated        | ✅
missing-release | helm                                    | error                        | ✅
missing-chart   | helm my-release                         | error                        | ✅

---

## steward:pip

Scenario      | Invocation               | Expected                  | ✓/✗
--------------|--------------------------|---------------------------|----
valid         | pip flask                | flask in manifest         | ✅
versioned     | pip flask@3.0.0          | version preserved         | ✅
batched       | pip a; pip b             | 2 entries in manifest     | ✅
unused        | (no pip calls)           | no manifest generated     | ✅
local-dir     | pip --dir /app           | venv + requirements.txt   | ✅
local-dir+pkg | pip --dir /app flask     | venv + pip install flask  | ✅
missing-name  | pip                      | error                     | ✅

---

## steward:go

Scenario      | Invocation                  | Expected                  | ✓/✗
--------------|-----------------------------|---------------------------|----
valid         | go golang.org/x/tools/gopls | @latest in manifest       | ✅
versioned     | go tool@v0.15.0             | version preserved         | ✅
batched       | go a; go b                  | 2 entries in manifest     | ✅
unused        | (no go calls)               | no manifest generated     | ✅
local-dir     | go --dir /app              | cd + go mod download      | ✅
local-dir+pkg | go --dir /app pkg           | cd + go get pkg@latest    | ✅
missing-name  | go                          | error                     | ✅

---

## steward:eager

Scenario      | Invocation                          | Expected                  | ✓/✗
--------------|-------------------------------------|---------------------------|----
valid         | eager setup <<<"echo hello"         | content in 0-00-eager-*   | ✅
custom-order  | eager :50 early <<<"x"              | 0-50-eager-* created      | ✅
base-range    | eager :99 max <<<"x"                  | 0-99-eager-* created      | ✅
no-name       | eager <<<"x"                        | rejects (name required)   | ✅

---

## steward:hook

Scenario        | Invocation                                | Expected                  | ✓/✗
----------------|-------------------------------------------|---------------------------|----
before-anchor   | hook --before npm name <<<"x"             | hook-before-npm-* created | ✅
after-anchor    | hook --after composer name <<<"x"         | hook-after-composer-* created | ✅
before-apt      | hook --before apt name <<<"x"             | hook-before-apt-* created | ✅
after-go        | hook --after go name <<<"x"               | hook-after-go-* created   | ✅
unknown-anchor  | hook --before nonexistent <<<"x"          | error                     | ✅
no-name         | hook --before apt <<<"x"                  | rejects (name required)   | ✅

---

## steward:defer

Scenario     | Invocation                   | Expected                   | ✓/✗
-------------|------------------------------|----------------------------|----
valid        | defer setup <<<"echo hello"  | content in 2-00-deferred-* | ✅
custom-order | defer :50 early <<<"x"       | 2-50-deferred-* created    | ✅
no-name      | defer <<<"x"                 | rejects (name required)    | ✅

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
no-side-effects | guard bash (in func1); func2    | func2 still runs              | ✅
force-flag      | --force; guard bash              | guard bypassed, task runs     | ✅

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
task-filter   | steward --task alpha      | only alpha runs       | ✅
task-unset    | steward (no --task)       | all functions run     | ✅


---

## Docker Integration Tests

> Running in: ubuntu:24.04

Scenario       | Invocation                   | Expected              | ✓/✗
---------------|------------------------------|-----------------------|----
apt-installs   | apt curl                     | curl works            | ✅
apt-try-missing| apt --try nonexistent        | exits 0               | ✅
bin-downloads  | bin jq https://...           | jq works              | ✅
defer-executes | defer <<< "echo X"           | X in output           | ✅
include-file   | include fixtures/test.sf     | included pkg works    | ✅
dockerfile-run | RUN steward (in Dockerfile)  | reads Stewardfile     | ✅
dockerfile-fifo| RUN ./steward (writerless FIFO) | no hang, reads Stewardfile | ✅


## Summary

| ✅ Pass | ❌ Fail | ⚠️ Error |
|---------|---------|----------|
| 123 | 0 | 0 |

