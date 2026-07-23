# steward Test Results

## steward:key

Scenario     | Invocation                      | Expected                  | ✓/✗
-------------|---------------------------------|---------------------------|----
valid        | key docker https://example/gpg  | URL + name in output      | ✅
missing-name | key                             | error                     | ✅
missing-url  | key docker                      | error                     | ✅
non-http-url | key docker ftp://example/key    | error                     | ✅

---

## steward:src

Scenario      | Invocation                              | Expected                    | ✓/✗
--------------|-----------------------------------------|-----------------------------|----
valid-full    | src docker https://repo jammy stable    | repo + dist + comp in output| ✅
valid-deb-url | src https://example.com/pkg.deb         | URL + dpkg in output        | ✅
no-key-flag   | src --no-key ppa https://repo jammy     | no signed-by in output      | ✅
minimal-repo  | src myrepo https://repo.example.com     | repo + signed-by, no dist   | ✅
missing-name  | src                                     | error                       | ✅
multi-comp    | src r https://u jammy main universe     | all components in output    | ✅
signed-by     | src docker https://repo jammy stable    | signed-by names the keyring | ✅

---

## steward:apt

Scenario     | Invocation          | Expected                 | ✓/✗
-------------|---------------------|--------------------------|----
valid        | apt vim             | vim in apt.pkgs          | ✅
versioned    | apt vim=2:8.2       | version preserved        | ✅
try-flag     | apt --try pkg       | pkg in apt-try.pkgs      | ✅
temp-flag    | apt --temp pkg      | pkg in apt-temp.pkgs only      | ✅
try+temp     | apt --try --temp pkg| pkg in apt-temp-try.pkgs only  | ✅
temp+explicit| apt --temp + apt pkg| pkg recorded as temp AND explicit | ✅
missing-name | apt                 | error                    | ✅

---

## steward:deb

Scenario    | Invocation                       | Expected            | ✓/✗
------------|----------------------------------|---------------------|----
valid       | deb https://example.com/pkg.deb          | URL in deb.pkgs + path in apt.pkgs     | ✅
try-flag    | deb --try https://example/pkg.deb        | URL in deb.pkgs + path in apt-try.pkgs | ✅
temp-flag   | deb --temp https://example/pkg.deb       | URL in deb.pkgs + path in apt-temp.pkgs only | ✅
try+temp    | deb --try --temp https://example/pkg.deb | path in apt-temp-try.pkgs only         | ✅
missing-url | deb                                      | error                                  | ✅
invalid-url | deb /local/path.deb                      | error                                  | ✅
slug-url    | deb https://ex/pkg_1.0~b+1_amd64.deb     | URL slugified into cache filename      | ✅

---

## steward:bin

Scenario     | Invocation                  | Expected                     | ✓/✗
-------------|-----------------------------|------------------------------|----
valid        | bin jq https://example/jq   | name + URL + path in output  | ✅
missing-name | bin                         | error                        | ✅
missing-url  | bin jq                      | error                        | ✅
non-http-url | bin jq /local/path/jq       | error                        | ✅

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
with-args   | ext url php -- --2 --dir=x  | args in output  | ✅
missing-url | ext                         | error           | ✅
no-shell    | ext https://get.docker.com  | defaults to bash| ✅

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
two-dirs      | npm --dir a x; --dir b y | one line per dir     | ✅
same-dir      | npm --dir a x; --dir a y | batched on one line  | ✅
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
two-dirs      | composer --dir a x; --dir b y  | one line per dir            | ✅
same-dir      | composer --dir a x; --dir a y  | batched on one line         | ✅
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
with-repo       | helm my-nginx bitnami/nginx https://... | repo in helm.lst             | ✅
repo-dedup      | helm a chart repo; helm b chart repo    | single repo entry            | ✅
guard-once      | helm a x; helm b y                      | both entries in manifest     | ✅
unused          | (no helm calls)                         | no manifest generated        | ✅
missing-release | helm                                    | error                        | ✅
missing-ns      | helm my-release bitnami/nginx            | error (no namespace)         | ✅
missing-chart   | helm default/my-release                  | error                        | ✅
empty-stdin     | helm ns/r chart < /dev/null              | no values file written       | ✅
version+timeout | helm ns/r chart@1.2.3 --timeout 300      | both pinned in manifest      | ✅

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
two-dirs      | pip --dir a x; --dir b y | one line per dir          | ✅
same-dir      | pip --dir a x; --dir a y | batched on one line       | ✅
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
two-dirs      | go --dir a x; --dir b y     | one line per dir          | ✅
same-dir      | go --dir a x; --dir a y     | batched on one line       | ✅
missing-name  | go                          | error                     | ✅

---

## steward::apply chown

Scenario          | Invocation                        | Expected                        | ✓/✗
------------------|-----------------------------------|---------------------------------|----
npm-no-sudo       | apply:npm (SUDO_USER unset)       | returns 0, no chown             | ✅
npm-sudo          | apply:npm (SUDO_USER set)         | chowns npm cache                | ✅
pip-no-sudo       | apply:pip (SUDO_USER unset)       | returns 0, no chown             | ✅
pip-sudo          | apply:pip (SUDO_USER set)         | chowns pip cache                | ✅
go-no-sudo        | apply:go (SUDO_USER unset)        | returns 0, no chown             | ✅
go-sudo           | apply:go (SUDO_USER set)          | chowns GOPATH + GOCACHE         | ✅
composer-no-sudo  | apply:composer (SUDO_USER unset)  | returns 0, no chown             | ✅
composer-sudo     | apply:composer (SUDO_USER set)    | chowns home + cache-dir         | ✅

---

## steward:eager

Scenario      | Invocation                          | Expected                  | ✓/✗
--------------|-------------------------------------|---------------------------|----
valid         | eager setup <<<"echo hello"         | content in eager-00-*     | ✅
custom-order  | eager :50 early <<<"x"              | eager-50-* created        | ✅
base-range    | eager :99 max <<<"x"                | eager-99-* created        | ✅
no-name       | eager <<<"x"                        | eager-00.sh created       | ✅
ord-no-name   | eager :50 <<<"x"                    | eager-50.sh created       | ✅
same-label    | eager setup x; eager setup y        | both lines, in order      | ✅
leading-zero  | eager :05 early <<<"x"              | eager-05-early.sh created | ✅

---

## steward:hook

Scenario        | Invocation                                | Expected                  | ✓/✗
----------------|-------------------------------------------|---------------------------|----
before-anchor   | hook --before npm name <<<"x"             | hook-before-npm-* created | ✅
after-anchor    | hook --after composer name <<<"x"         | hook-after-composer-* created | ✅
before-apt      | hook --before apt name <<<"x"             | hook-before-apt-* created | ✅
after-go        | hook --after go name <<<"x"               | hook-after-go-* created   | ✅
custom-order    | hook --before apt :50 name <<<"x"         | hook-before-apt-50-* created | ✅
no-name         | hook --before apt <<<"x"                  | hook-before-apt-00.sh created | ✅
no-anchor       | hook name <<<"x"                          | error                     | ✅
before+after    | hook --before apt; hook --after apt        | both files created        | ✅
same-label      | hook --before apt setup x; ... y           | both lines, in order      | ✅

---

## steward:defer

Scenario     | Invocation                   | Expected                   | ✓/✗
-------------|------------------------------|----------------------------|----
valid        | defer setup <<<"echo hello"  | content in defer-00-*      | ✅
custom-order | defer :50 early <<<"x"       | defer-50-* created         | ✅
base-range   | defer :99 max <<<"x"         | defer-99-* created         | ✅
no-name      | defer <<<"x"                 | defer-00.sh created        | ✅
ord-no-name  | defer :50 <<<"x"             | defer-50.sh created        | ✅
same-label   | defer setup x; defer setup y | both lines, in order       | ✅

---

## steward:on-amd64 / steward:on-arm64

Scenario       | Invocation                  | Expected                 | ✓/✗
---------------|-----------------------------|--------------------------|----
amd64-on-amd64 | ARCH=amd64; on-amd64 apt vim   | vim in packages       | ✅
amd64-on-arm64 | ARCH=arm64; on-amd64 apt vim   | vim NOT in packages   | ✅
arm64-on-arm64 | ARCH=arm64; on-arm64 apt vim   | vim in packages       | ✅
arm64-on-amd64 | ARCH=amd64; on-arm64 apt vim   | vim NOT in packages   | ✅
no-globbing    | ARCH=amd64; on-amd64 apt '*'   | literal * in packages | ✅
whitespace     | on-amd64 apt 'pkg with space'  | argument kept intact  | ✅

---

## steward:in-dev

Scenario       | Invocation                    | Expected              | ✓/✗
---------------|-------------------------------|-----------------------|----
app-env-dev    | APP_ENV=dev; in-dev apt vim   | vim in packages       | ✅
app-debug-1    | APP_DEBUG=1; in-dev apt vim   | vim in packages       | ✅
debug-set      | DEBUG=1; in-dev apt vim       | vim in packages       | ✅
app-env-prod   | APP_ENV=prod; in-dev apt vim  | vim NOT in packages   | ✅
env-unset      | in-dev apt vim                | vim NOT in packages   | ✅
no-globbing    | APP_ENV=dev; in-dev apt '*'   | literal * in packages | ✅

---

## steward:include

Scenario     | Invocation             | Expected                  | ✓/✗
-------------|------------------------|---------------------------|----
local-file   | include test.sf        | included content processed| ✅
missing-file | include /nonexistent   | error                     | ✅
nested       | include a (a includes b) | both files processed    | ✅
relative     | include ./file          | resolved against cwd     | ✅

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
pkg-present     | guard --pkg bash                | exits subshell (skip)         | ✅
pkg-absent      | guard --pkg nonexistent         | continues execution           | ✅
cmd-success     | guard --cmd 'true'              | exits subshell (skip)         | ✅
cmd-failure     | guard --cmd 'false'             | continues execution           | ✅
cmd-multi-word  | guard --cmd 'test -d /tmp && …' | exits subshell (skip)         | ✅
force-file      | force=true; guard --file exists | guard bypassed                | ✅
force-dir       | force=true; guard --dir /tmp    | guard bypassed                | ✅
force-pkg       | force=true; guard --pkg bash    | guard bypassed                | ✅
force-cmd       | force=true; guard --cmd 'true'  | guard bypassed                | ✅
second-guard    | guard absent; guard --cmd false | both evaluated, task runs     | ✅

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
help          | steward --help            | usage guide printed   | ✅
namespace     | steward -n st:            | st:apt keyword works  | ✅
trace         | steward -x app            | trace on stderr       | ✅
dist-fallback | steward (Stewardfile.dist)| .dist file used       | ✅
task-keyword  | task alpha() { ... }      | task = function alias | ✅
env-os        | apt "pkg-$ARCH-$ID"     | ARCH/ID/codename set  | ✅
env-dir       | apt "pkg-$STEWARDFILE_DIR" | STEWARDFILE_DIR set | ✅
wipes-tmp     | stale file in /tmp/steward| wiped on start        | ✅
dedup         | apt dup; apt dup          | one entry after apply | ✅
missing-file  | steward /nonexistent      | error                 | ✅
sourced       | source ./steward          | exports, does not run | ✅

---

## steward::apply package managers

Scenario         | Invocation                       | Expected                              | ✓/✗
-----------------|----------------------------------|---------------------------------------|----
npm-global       | apply:npm (!global yarn ts)      | npm install --global yarn ts          | ✅
npm-dir          | apply:npm (dir, no packages)     | cd dir + npm install                  | ✅
npm-dir+pkg      | apply:npm (dir + packages)       | cd dir + npm install express react    | ✅
composer-global  | apply:composer (!global pkg)     | composer global require pkg           | ✅
composer-version | apply:composer (pkg@^4.0)        | @ rewritten to : constraint           | ✅
composer-dir     | apply:composer (dir, no pkgs)    | cd dir + composer install             | ✅
composer-dir+pkg | apply:composer (dir + packages)  | cd dir + composer require pkg         | ✅
pip-global       | apply:pip (!global flask)        | pip3 install --break-system-packages  | ✅
pip-version      | apply:pip (flask@3.0.0)          | @ rewritten to == constraint          | ✅
pip-dir          | apply:pip (dir, no packages)     | venv + pip install -r requirements    | ✅
pip-dir+pkg      | apply:pip (dir + packages)       | venv + pip install flask==3.0.0       | ✅
go-global        | apply:go (!global a b)           | one go install per package            | ✅
go-dir           | apply:go (dir, no packages)      | cd dir + go mod download              | ✅
go-dir+pkg       | apply:go (dir + packages)        | cd dir + go get pkg@latest            | ✅

---

## steward::apply:helm

Scenario        | Invocation                         | Expected                                | ✓/✗
----------------|------------------------------------|-----------------------------------------|----
defaults        | apply:helm (bare release)          | upgrade --install --atomic --wait 60s   | ✅
version         | apply:helm (version 1.2.3)         | --version 1.2.3                         | ✅
timeout         | apply:helm (timeout 300)           | --timeout 300s                          | ✅
values          | apply:helm (values file)           | --values <file>                         | ✅
repos           | apply:helm (helm.lst present)      | helm repo add + helm repo update        | ✅
multi-release   | apply:helm (two releases)          | both installed                          | ✅
failure         | apply:helm (helm exits 1)          | returns 1, names the failed release     | ✅
no-kubernetes   | apply:helm (kubectl always fails)  | times out, no helm upgrade issued       | ✅

---

## steward::apply:eager / :hook / :defer

Scenario        | Invocation                          | Expected                          | ✓/✗
----------------|-------------------------------------|-----------------------------------|----
eager-order     | eager-10-a.sh, eager-50-b.sh        | executed in ord order             | ✅
eager-failure   | eager script exits non-zero         | ERROR on stderr, exit 1           | ✅
eager-empty     | no eager scripts                    | no-op, returns 0                  | ✅
defer-order     | defer-10-a.sh, defer-50-b.sh        | executed in ord order             | ✅
defer-failure   | defer script exits non-zero         | ERROR on stderr, exit 1           | ✅
hook-stage      | before-apt, after-apt, before-npm   | only the named stage runs         | ✅
hook-order      | hook-before-apt-10 / -50            | executed in ord order             | ✅
hook-failure    | hook script exits non-zero          | ERROR on stderr, exit 1           | ✅
hook-empty      | no hook scripts for stage           | no-op, returns 0                  | ✅

---

## steward::apply:prereqs / :clean-up / dry-run

Scenario         | Invocation                          | Expected                                | ✓/✗
-----------------|-------------------------------------|-----------------------------------------|----
cache-dir        | apply:prereqs                       | /var/cache/steward created              | ✅
lists-empty      | apply:prereqs (no apt lists)        | apt update                              | ✅
lists-present    | apply:prereqs (apt lists present)   | no apt update                           | ✅
curl-gpg-missing | apply:prereqs (empty PATH)          | installs apt-transport-https/curl/gpg   | ✅
outside-buildkit | apply:clean-up (plain container)    | no-op, nothing removed                  | ✅
temp-removed     | apt --temp build-dep; apt vim       | build-dep removed                       | ✅
explicit-kept    | apt --temp build-dep; apt vim       | vim never removed                       | ✅
temp-alone       | apt --temp build-dep                | build-dep removed                       | ✅
try-temp         | apt --try --temp build-dep          | build-dep removed                       | ✅
mounted-caches   | apply:clean-up (caches mounted)     | apt clean skipped, lists kept           | ✅
dry-run          | dry-run (apt.pkgs + key.lst)        | every manifest printed with a header    | ✅

---

## steward::prereq:*

Scenario         | Invocation                         | Expected                                | ✓/✗
-----------------|------------------------------------|-----------------------------------------|----
zip-unused       | prereq:zip (no zip.pkgs)           | nothing scheduled                       | ✅
zip-missing      | prereq:zip (unzip absent)          | apt --temp unzip                        | ✅
zip-present      | prereq:zip (unzip present)         | nothing scheduled                       | ✅
npm-plain        | prereq:npm (NODEVS unset)          | apt nodejs, no repo                     | ✅
npm-nodevs       | prereq:npm (NODEVS=20)             | nodesource key + node_20.x repo         | ✅
composer-debian  | prereq:composer (ID=debian)        | sury repo for the codename              | ✅
composer-ubuntu  | prereq:composer (ID=ubuntu)        | ondrej PPA for the codename             | ✅
composer-phpvs   | prereq:composer (PHPVS=8.2)        | php8.2-cli scheduled                    | ✅
composer-present | prereq:composer (php present)      | nothing scheduled                       | ✅
helm-missing     | prereq:helm (helm absent)          | buildkite key + repo + apt helm         | ✅
helm-present     | prereq:helm (helm present)         | nothing scheduled                       | ✅
pip-missing      | prereq:pip (pip3 absent)           | apt --temp python3-pip + python3-venv   | ✅
go-missing       | prereq:go (go absent)              | apt golang                              | ✅
go-present       | prereq:go (go present)             | nothing scheduled                       | ✅


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

### Download-and-install stages (fixture image)

Scenario        | Invocation                              | Expected                              | ✓/✗
----------------|-----------------------------------------|---------------------------------------|----
key-armored     | key fixture http://.../key.asc          | dearmored keyring, 644 root:root      | ✅
key-binary      | key fixture http://.../key.gpg          | copied verbatim                       | ✅
src-list        | src myrepo http://... jammy main uni    | sources.list.d entry, 644 root:root   | ✅
src-no-key      | src --no-key myrepo http://... jammy    | no signed-by in the list              | ✅
src-deb-url     | src http://.../fixture.deb              | package installed                     | ✅
deb-installs    | deb http://.../fixture.deb              | package installed                     | ✅
bin-executable  | bin mybin http://.../mybin              | executable in /usr/local/bin, runs    | ✅
tar-installs    | tar mytool bin/mytool http://...tgz     | binary runs, no /opt/mytool           | ✅
tar-keep        | tar --keep mytool bin/mytool ...        | /opt/mytool + symlink                 | ✅
zip-installs    | zip mytool bin/mytool http://...zip     | unzip prereq installed, binary runs   | ✅
zip-keep        | zip --keep mytool bin/mytool ...        | /opt/mytool + symlink                 | ✅
ext-args        | ext http://.../installer.sh sh -s -- --flag | script runs with args             | ✅
eager-first     | eager marker; apt curl; defer check     | eager ran before packages             | ✅
hooks           | hook --before/--after apt               | both hooks ran around the stage       | ✅
guard-skips     | guard --cmd true; apt wget              | task skipped, wget absent             | ✅
url-argument    | steward http://.../remote.Stewardfile   | remote Stewardfile processed          | ✅
pip-installs    | pip six                                 | python3 -c "import six" works         | ✅
sudo-reexec     | ./steward as unprivileged user          | re-execs under sudo, installs         | ✅
sudo-user       | defer echo $USER (run via sudo)        | USER/HOME are the invoking human      | ✅

### BuildKit clean-up (only armed inside an image build)

Scenario         | Invocation                        | Expected                         | ✓/✗
-----------------|-----------------------------------|----------------------------------|----
clean-up-runs    | RUN ./steward (apt --temp jq)     | build succeeds                   | ✅
temp-removed     | apt --temp jq; apt wget           | jq gone from the final image     | ✅
requested-kept   | apt --temp jq; apt wget           | wget kept in the final image     | ✅


## Summary

| ✅ Pass | ❌ Fail | ⚠️ Error |
|---------|---------|----------|
| 267 | 0 | 0 |

