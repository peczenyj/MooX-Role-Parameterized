# Phase 3 — Dist::Zilla Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate `MooX::Role::Parameterized` off `ExtUtils::MakeMaker` to Dist::Zilla, so `$VERSION` is single-sourced and injected identically into all four packages, `README.md` is generated from POD, CI is modernized, and `release.yml` gains real gates.

**Architecture:** A new `dist.ini` drives the build. `[OurPkgVersion]` injects one version (from `dist.ini`) into every module's `# VERSION` marker at build time. `[@Basic]` provides the core plugin set; layered plugins add JSON metadata, README generation, and author tests. `Makefile.PL`/`MANIFEST` become generated build artifacts and leave git. CI workflows switch to the `dzil` idiom.

**Tech Stack:** Perl 5.12+, Dist::Zilla 6, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-05-16-phase-3-tooling-design.md`

**Branch:** All work happens on `feature/phase-3-tooling`, branched from `devel`.

---

## Context an engineer needs before starting

- The distribution has four modules, all currently opening with `package NAME 0.601;`:
  - `lib/MooX/Role/Parameterized.pm` — the main module
  - `lib/MooX/Role/Parameterized/Mop.pm`
  - `lib/MooX/Role/Parameterized/With.pm`
  - `lib/MooX/Role/Parameterized/Cookbook.pm`
- `[OurPkgVersion]` (Dist::Zilla plugin) replaces a `# VERSION` comment line with `our $VERSION = '<dist version>';` at build time. It does **nothing** to a file that has no `# VERSION` marker, and it conflicts with a literal version in the `package` statement — so each module must drop its literal version and gain a `# VERSION` marker.
- `dzil build` produces a `MooX-Role-Parameterized-<version>/` directory and a `.tar.gz`. Inspecting the built directory is how every task is verified.
- `dzil test --all` builds the dist into a temp directory and runs `t/` plus author tests (`xt/`) there.
- The repo working copy carries **no** literal `$VERSION` after this migration; only the built tarball does. Tests never assert on `$VERSION`, so `prove -lr t` against the working copy is unaffected.

---

## Task 1: Bootstrap the toolchain and branch

**Files:**
- None modified — environment setup only.

- [ ] **Step 1: Create the feature branch**

```bash
cd /home/tiago/work/perl/MooX-Role-Parameterized
git checkout devel
git pull --ff-only
git checkout -b feature/phase-3-tooling
```

- [ ] **Step 2: Install cpanminus (fatpacked, no sudo)**

```bash
curl -L https://cpanmin.us -o /tmp/cpanm
chmod +x /tmp/cpanm
```

- [ ] **Step 3: Set up a local::lib library and install Dist::Zilla**

```bash
/tmp/cpanm --local-lib=$HOME/perl5 local::lib
eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"
/tmp/cpanm -nq Dist::Zilla
```

Add the `eval` line to the shell session for every later task, or prefix `dzil` calls with it. To make later steps deterministic, export it:

```bash
export PERL5LIB="$HOME/perl5/lib/perl5:$PERL5LIB"
export PATH="$HOME/perl5/bin:$PATH"
```

- [ ] **Step 4: Verify the toolchain**

Run: `dzil version`
Expected: a line like `This is Dist::Zilla version 6.xxx ...`

If this fails (no network, no write permission), the task is **BLOCKED** — the rest of the plan cannot be verified. Report the blocker; do not proceed.

- [ ] **Step 5: No commit**

This task changes no tracked files. Nothing to commit. Proceed to Task 2.

---

## Task 2: Core migration — `dist.ini`, version markers, remove EUMM files

This is the keystone task. After it, `dzil build` works and the EUMM build is gone.

**Files:**
- Create: `dist.ini`
- Modify: `lib/MooX/Role/Parameterized.pm:1`
- Modify: `lib/MooX/Role/Parameterized/Mop.pm:1`
- Modify: `lib/MooX/Role/Parameterized/With.pm:1`
- Modify: `lib/MooX/Role/Parameterized/Cookbook.pm:1`
- Modify: `MANIFEST.SKIP`
- Delete: `Makefile.PL`, `MANIFEST`, `Makefile.old`

- [ ] **Step 1: Convert each module to a `# VERSION` marker**

In each of the four modules, replace the first line. The pattern is identical for all four — only the package name differs.

`lib/MooX/Role/Parameterized.pm` line 1:
```perl
package MooX::Role::Parameterized 0.601;
```
becomes:
```perl
package MooX::Role::Parameterized;
# VERSION
```

`lib/MooX/Role/Parameterized/Mop.pm` line 1:
```perl
package MooX::Role::Parameterized::Mop 0.601;
```
becomes:
```perl
package MooX::Role::Parameterized::Mop;
# VERSION
```

`lib/MooX/Role/Parameterized/With.pm` line 1:
```perl
package MooX::Role::Parameterized::With 0.601;
```
becomes:
```perl
package MooX::Role::Parameterized::With;
# VERSION
```

`lib/MooX/Role/Parameterized/Cookbook.pm` line 1:
```perl
package MooX::Role::Parameterized::Cookbook 0.601;
```
becomes:
```perl
package MooX::Role::Parameterized::Cookbook;
# VERSION
```

Leave every other line (the `use v5.12;`, `use strict;`, `# ABSTRACT:` lines, etc.) untouched.

- [ ] **Step 2: Create `dist.ini`**

Create `dist.ini` at the repository root with exactly this content:

```ini
name             = MooX-Role-Parameterized
author           = Tiago Peczenyj <tiago.peczenyj+cpan@gmail.com>
license          = MIT
copyright_holder = Tiago Peczenyj
copyright_year   = 2026
version          = 0.700

[@Basic]
; @Basic ships a plain-text Readme (superseded by ReadmeAnyFromPod),
; a License plugin (the repo already tracks a LICENSE file, so keep that
; one and avoid a duplicate-file error), and UploadToCPAN (CI uploads;
; dzil is build-only here).
[@Basic] / -remove = Readme
[@Basic] / -remove = License
[@Basic] / -remove = UploadToCPAN

[OurPkgVersion]
[MetaJSON]
[MetaProvides::Package]

[Authority]
authority  = cpan:PACMAN
do_munging = 0

[MetaResources]
homepage        = https://github.com/peczenyj/MooX-Role-Parameterized
repository.url  = https://github.com/peczenyj/MooX-Role-Parameterized.git
repository.web  = https://github.com/peczenyj/MooX-Role-Parameterized
repository.type = git
bugtracker.web  = https://github.com/peczenyj/MooX-Role-Parameterized/issues

[NextRelease]
filename = Changelog
format   = %-7v %{EEE MMM dd yyyy HH:mm:ss zzz}d

[ReadmeAnyFromPod]
type     = markdown
filename = README.md
location = root

[Prereqs]
perl             = 5.012
Carp             = 0
Module::Runtime  = 0
Moo              = 2
MooX::BuildClass = 0.213360

[Prereqs / TestRequires]
Role::Tiny      = 2.000000
Test::Exception = 0.43
Test::More      = 0.94
Test::Pod       = 0

[Prereqs / DevelopRequires]
Dist::Zilla        = 6
Test::Perl::Critic = 0
Test::PerlTidy     = 0
Test::Synopsis     = 0
Type::Tiny         = 0
Perl::Critic::Policy::Documentation::RequirePodLinksIncludeText = 0
Perl::Critic::Policy::Miscellanea::RequireRcsKeywords           = 0
```

The `[Test::*]` author-test plugins are added later, in Task 4.

- [ ] **Step 3: Edit `MANIFEST.SKIP`**

`MANIFEST.SKIP` currently contains, among other lines, `META.yml` and `^xt/`. Remove **both** of those two lines:
- `META.yml` — Dist::Zilla's `[MetaYAML]` generates `META.yml` as a file that must ship; this skip rule would prune it.
- `^xt/` — the author tests must ship in the tarball (standard DZ practice).

Leave every other line (`^\.`, `^docs/`, `Makefile$`, `^MYMETA\.`, `blib/`, `^author/`, etc.) unchanged.

- [ ] **Step 4: Delete the EUMM build files**

```bash
git rm Makefile.PL MANIFEST Makefile.old
```

- [ ] **Step 5: Install the plugin dependencies declared by `dist.ini`**

```bash
dzil authordeps --missing | /tmp/cpanm -nq
dzil listdeps --missing | /tmp/cpanm -nq
```

- [ ] **Step 6: Build the distribution**

Run: `dzil build`
Expected: succeeds, ending with a line like `built in MooX-Role-Parameterized-0.700`. No error about duplicate files or missing version.

- [ ] **Step 7: Verify version injection into all four modules**

Run:
```bash
grep -H 'our $VERSION' MooX-Role-Parameterized-0.700/lib/MooX/Role/Parameterized.pm \
  MooX-Role-Parameterized-0.700/lib/MooX/Role/Parameterized/Mop.pm \
  MooX-Role-Parameterized-0.700/lib/MooX/Role/Parameterized/With.pm \
  MooX-Role-Parameterized-0.700/lib/MooX/Role/Parameterized/Cookbook.pm
```
Expected: four lines, each containing `our $VERSION = '0.700';`.

- [ ] **Step 8: Verify the EUMM build still works for end users**

Run:
```bash
cd MooX-Role-Parameterized-0.700 && perl Makefile.PL && make test 2>&1 | tail -5 ; cd ..
```
Expected: the generated `Makefile.PL` runs and `make test` reports `Result: PASS`.

- [ ] **Step 9: Clean the build artifact and commit**

```bash
rm -rf MooX-Role-Parameterized-0.700 MooX-Role-Parameterized-0.700.tar.gz
git add dist.ini MANIFEST.SKIP lib/
git commit -m "Phase 3: replace EUMM build with Dist::Zilla

Add dist.ini, convert the four modules to # VERSION markers injected by
[OurPkgVersion], drop Makefile.PL/MANIFEST/Makefile.old (now generated
build artifacts), and adjust MANIFEST.SKIP for the DZ-managed MANIFEST.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 3: README generation with badges

`[ReadmeAnyFromPod]` (already in `dist.ini`) regenerates `README.md` from the main module's POD. The status badges currently in `README.md` are not in any POD, so they must move into the main module's POD to survive regeneration.

**Files:**
- Modify: `lib/MooX/Role/Parameterized.pm` (POD `=head1 NAME` area, around line 184)

- [ ] **Step 1: Capture the current badge block**

The badge block to embed is the markdown badge lines currently at the top of `README.md` (between the `# NAME` heading and `## SYNOPSIS`). Read them from the current `README.md` — there are seven: Kwalitee, the linux/windows/macos workflow badges, Coverage Status, license, and cpan.

- [ ] **Step 2: Embed the badges in the main module POD**

In `lib/MooX/Role/Parameterized.pm`, the POD currently reads:

```pod
=head1 NAME

MooX::Role::Parameterized - roles with composition parameters

=head1 SYNOPSIS
```

Insert a `=begin :markdown` region between the NAME paragraph and `=head1 SYNOPSIS`:

```pod
=head1 NAME

MooX::Role::Parameterized - roles with composition parameters

=begin :markdown

[![Kwalitee](https://cpants.cpanauthors.org/dist/MooX-Role-Parameterized.svg)](https://cpants.cpanauthors.org/dist/MooX-Role-Parameterized)
[![tests](https://github.com/peczenyj/MooX-Role-Parameterized/actions/workflows/linux.yml/badge.svg)](https://github.com/peczenyj/MooX-Role-Parameterized/actions/workflows/linux.yml)
[![tests](https://github.com/peczenyj/MooX-Role-Parameterized/actions/workflows/windows.yml/badge.svg)](https://github.com/peczenyj/MooX-Role-Parameterized/actions/workflows/windows.yml)
[![tests](https://github.com/peczenyj/MooX-Role-Parameterized/actions/workflows/macos.yml/badge.svg)](https://github.com/peczenyj/MooX-Role-Parameterized/actions/workflows/macos.yml)
[![Coverage Status](https://coveralls.io/repos/github/peczenyj/MooX-Role-Parameterized/badge.svg?branch=master)](https://coveralls.io/github/peczenyj/MooX-Role-Parameterized?branch=master)
[![license](https://img.shields.io/cpan/l/MooX-Role-Parameterized.svg)](https://github.com/peczenyj/MooX-Role-Parameterized/blob/master/LICENSE)
[![cpan](https://img.shields.io/cpan/v/MooX-Role-Parameterized.svg)](https://metacpan.org/dist/MooX-Role-Parameterized)

=end :markdown

=head1 SYNOPSIS
```

Use the exact badge URLs from the current `README.md` — copy them verbatim rather than retyping.

- [ ] **Step 3: Regenerate the README**

Run: `dzil build`
Expected: succeeds. `[ReadmeAnyFromPod]` rewrites `README.md` in the repo root.

- [ ] **Step 4: Verify the regenerated README**

Run: `head -20 README.md`
Expected: the `# NAME` heading, then the seven `[![...](...)](...)` badge lines as **literal, unescaped** markdown (not `\[\!\[...`), then the SYNOPSIS.

If the badge lines come back escaped (backslashes before brackets), `Pod::Markdown` parsed the region as POD text. Fix: change `=begin :markdown` / `=end :markdown` to `=begin markdown` / `=end markdown` (drop the colon, making it a verbatim data region) and rebuild.

- [ ] **Step 5: Clean and commit**

```bash
rm -rf MooX-Role-Parameterized-0.700 MooX-Role-Parameterized-0.700.tar.gz
git add lib/MooX/Role/Parameterized.pm README.md
git commit -m "Phase 3: source README badges from module POD

Move the status badges into the main module's POD inside a markdown
region so [ReadmeAnyFromPod] carries them into every regenerated
README.md.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 4: Author tests via Dist::Zilla plugins

Replace the hand-written `xt/` tests with DZ-generated equivalents, keep the project-specific `examples.t`, and ship the lint config files so the generated tests can find them.

**Files:**
- Rename: `.perlcriticrc` → `perlcriticrc`
- Rename: `.perltidyrc` → `perltidyrc`
- Rename: `xt/examples.t` → `xt/author/examples.t`
- Delete: `xt/version.t`, `xt/perlcritic.t`, `xt/perltidy.t`, `xt/synopsis.t`
- Modify: `dist.ini`

- [ ] **Step 1: Rename the lint config files so they ship**

`.perlcriticrc` and `.perltidyrc` are dotfiles; `MANIFEST.SKIP`'s `^\.` rule prunes them, so they would not ship in the tarball and the generated author tests (which run against the built dist) could not find them. Rename them to non-dotfiles:

```bash
git mv .perlcriticrc perlcriticrc
git mv .perltidyrc perltidyrc
```

- [ ] **Step 2: Move the examples test under `xt/author/`**

```bash
git mv xt/examples.t xt/author/examples.t
```

`xt/author/examples.t` needs no content change — it globs `examples/*.pl` relative to the dist root, which is correct in the built dist.

- [ ] **Step 3: Delete the superseded hand-written author tests**

```bash
git rm xt/version.t xt/perlcritic.t xt/perltidy.t xt/synopsis.t
```

- `version.t` — obsolete; `[OurPkgVersion]` guarantees coherence.
- `perlcritic.t`, `perltidy.t`, `synopsis.t` — replaced by DZ plugins below.

- [ ] **Step 4: Add the author-test plugins to `dist.ini`**

Append to the end of `dist.ini`:

```ini
[Test::Perl::Critic]
critic_config = perlcriticrc

[Test::PerlTidy]
[Test::Synopsis]
[Test::Compile]
[Test::Version]
[PodSyntaxTests]
[Test::CPAN::Changes]
```

`[Test::PerlTidy]` finds the dist-root `perltidyrc` automatically. `[Test::Compile]` generates a regular `t/` test; the others generate `xt/author/` tests.

- [ ] **Step 5: Install the new plugin dependencies**

```bash
dzil authordeps --missing | /tmp/cpanm -nq
dzil listdeps --develop --missing | /tmp/cpanm -nq
```

The `--develop` flag pulls in `Type::Tiny` (the SYNOPSIS uses `Types::Standard`) and the perlcritic policy distributions, which the generated author tests need.

- [ ] **Step 6: Run the full test suite**

Run: `dzil test --all`
Expected: builds the dist and runs `t/` plus all `xt/author/` tests; ends with `Result: PASS` (or per-file `PASS`) and no failures.

If `xt/author/cpan-changes.t` fails because `CPAN::Changes` cannot parse the `Changelog` date format, normalize the date on each version line in `Changelog` to ISO `YYYY-MM-DD` (e.g. `0.601   2026-05-16`) and rerun. Leave the bullet lines unchanged.

- [ ] **Step 7: Clean and commit**

```bash
rm -rf MooX-Role-Parameterized-0.700 MooX-Role-Parameterized-0.700.tar.gz .build
git add dist.ini perlcriticrc perltidyrc xt/ Changelog
git commit -m "Phase 3: author tests via Dist::Zilla plugins

Replace the hand-written perlcritic/perltidy/synopsis/version xt tests
with [Test::*] plugins, add Test::Compile/Test::Version/PodSyntaxTests/
Test::CPAN::Changes for broader coverage, keep examples.t as
xt/author/examples.t, and un-dot the lint config files so they ship.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 5: Modernize the test CI workflows

With `Makefile.PL` gone from the repo, `cpanm --installdeps .` has no metadata to read. All three OS workflows move to the `dzil` idiom.

**Files:**
- Modify: `.github/workflows/linux.yml`
- Modify: `.github/workflows/macos.yml`
- Modify: `.github/workflows/windows.yml`

- [ ] **Step 1: Rewrite `.github/workflows/linux.yml`**

Replace the entire file with:

```yaml
---
name: linux

on:
  - push

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        perl: ["5.12", "5.20", "5.30"]
        include:
          - perl: 'latest'
            coverage: true
    name: Perl ${{ matrix.perl }} on ubuntu
    steps:
      - uses: actions/checkout@v4
      - name: Set up perl
        uses: shogo82148/actions-setup-perl@v1
        with:
          perl-version: ${{ matrix.perl }}
      - run: perl -V
      - run: cpanm -nq Dist::Zilla
      - name: Install author and runtime dependencies
        run: |
          dzil authordeps --missing | cpanm -nq
          dzil listdeps --develop --missing | cpanm -nq
      - name: Run tests
        run: dzil test --all
      - name: Run tests (with coverage)
        if: ${{ matrix.coverage }}
        env:
          GITHUB_ACTIONS: true
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          COVERALLS_REPO_TOKEN: ${{ secrets.COVERALLS_REPO_TOKEN }}
        run: |
          cpanm -nq Devel::Cover::Report::Coveralls Dist::Zilla::App::Command::cover
          dzil cover -test -report Coveralls
```

- [ ] **Step 2: Rewrite `.github/workflows/macos.yml`**

Replace the entire file with:

```yaml
---
name: macos

on:
  - push

jobs:
  perl:
    runs-on: macOS-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shogo82148/actions-setup-perl@v1
        with:
          perl-version: "5.40"
      - run: perl -V
      - run: cpanm -nq Dist::Zilla
      - name: Install author and runtime dependencies
        run: |
          dzil authordeps --missing | cpanm -nq
          dzil listdeps --develop --missing | cpanm -nq
      - name: Run tests
        run: dzil test --all
```

- [ ] **Step 3: Rewrite `.github/workflows/windows.yml`**

Replace the entire file with:

```yaml
---
name: windows

on:
  - push

jobs:
  perl:
    runs-on: windows-latest
    steps:
      - name: Set git to use LF
        run: |
          git config --global core.autocrlf false
          git config --global core.eol lf
      - uses: actions/checkout@v4
      - uses: shogo82148/actions-setup-perl@v1
        with:
          perl-version: "5.40"
          distribution: strawberry
      - run: perl -V
      - run: cpanm -nq Dist::Zilla
      - name: Install author and runtime dependencies
        run: |
          dzil authordeps --missing | cpanm -nq
          dzil listdeps --develop --missing | cpanm -nq
      - name: Run tests
        run: dzil test --all
```

- [ ] **Step 4: Validate the YAML**

Run: `perl -MYAML::PP -e 'YAML::PP->new->load_file($_) for @ARGV' .github/workflows/linux.yml .github/workflows/macos.yml .github/workflows/windows.yml && echo OK`
Expected: `OK` (install `YAML::PP` with `/tmp/cpanm -nq YAML::PP` first if missing).

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/linux.yml .github/workflows/macos.yml .github/workflows/windows.yml
git commit -m "Phase 3: move CI workflows to the dzil idiom

linux/macos/windows now install Dist::Zilla, resolve deps via dzil
authordeps/listdeps, and run dzil test --all. The linux matrix expands
to Perl 5.12, 5.20, 5.30, and latest.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 6: Harden `release.yml`

Rebuild the release workflow on Dist::Zilla and add the version/tag and test gates Phase 2 never shipped.

**Files:**
- Modify: `.github/workflows/release.yml`

- [ ] **Step 1: Rewrite `.github/workflows/release.yml`**

Replace the entire file with:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    name: Build, CPAN and GitHub Release
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Perl
        uses: shogo82148/actions-setup-perl@v1
        with:
          perl-version: 'latest'

      - name: Install Dist::Zilla and dependencies
        run: |
          cpanm -nq Dist::Zilla CPAN::Uploader
          dzil authordeps --missing | cpanm -nq
          dzil listdeps --develop --missing | cpanm -nq

      - name: Gate - tag matches dist.ini version
        run: |
          tag_version="${GITHUB_REF_NAME#v}"
          ini_version="$(perl -ne 'print $1 if /^version\s*=\s*(\S+)/' dist.ini)"
          echo "tag=$tag_version dist.ini=$ini_version"
          if [ "$tag_version" != "$ini_version" ]; then
            echo "::error::tag $GITHUB_REF_NAME does not match dist.ini version $ini_version"
            exit 1
          fi

      - name: Gate - tests
        run: dzil test --all

      - name: Build distribution
        run: dzil build

      - name: Upload to CPAN
        if: env.PAUSE_USER != ''
        env:
          PAUSE_USER: ${{ secrets.PAUSE_USER }}
          PAUSE_PASSWORD: ${{ secrets.PAUSE_PASSWORD }}
        run: |
          cpan-upload -u "$PAUSE_USER" -p "$PAUSE_PASSWORD" MooX-Role-Parameterized-*.tar.gz

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: MooX-Role-Parameterized-*.tar.gz
          generate_release_notes: true
          draft: false
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

The `PAUSE_USER` / `PAUSE_PASSWORD` secret names are kept exactly as the working v0.601 release used them. The `if: env.PAUSE_USER != ''` guard lets forks push tags without secrets and skip the upload.

- [ ] **Step 2: Verify the version-gate logic locally**

The gate compares `${GITHUB_REF_NAME#v}` to the `version =` line in `dist.ini`. Verify the extraction works:

Run: `perl -ne 'print $1 if /^version\s*=\s*(\S+)/' dist.ini`
Expected: `0.700`

Simulate a matching tag (`v0.700`) and a mismatched tag (`v0.699`):
```bash
for tag in v0.700 v0.699; do
  tv="${tag#v}"
  iv="$(perl -ne 'print $1 if /^version\s*=\s*(\S+)/' dist.ini)"
  [ "$tv" = "$iv" ] && echo "$tag -> PASS" || echo "$tag -> FAIL (gate aborts)"
done
```
Expected: `v0.700 -> PASS` and `v0.699 -> FAIL (gate aborts)`.

- [ ] **Step 3: Validate the YAML**

Run: `perl -MYAML::PP -e 'YAML::PP->new->load_file("$ARGV[0]")' .github/workflows/release.yml && echo OK`
Expected: `OK`.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/release.yml
git commit -m "Phase 3: harden release.yml with version and test gates

Rebuild release.yml on Dist::Zilla and add the gates Phase 2 never
shipped: abort if the tag does not match dist.ini's version, and run
dzil test --all before building and uploading.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 7: Sync `AGENTS.md` and the `Changelog`

**Files:**
- Modify: `AGENTS.md`
- Modify: `Changelog`

- [ ] **Step 1: Update `AGENTS.md` "Common commands"**

In `AGENTS.md`, the "Common commands" section documents the `ExtUtils::MakeMaker` build (`perl Makefile.PL` / `make` / `make test`). Replace the build/test instructions with the Dist::Zilla idiom. Change the "Build / test (ExtUtils::MakeMaker)" block to:

```
Build / test (Dist::Zilla):

    cpanm -nq Dist::Zilla
    dzil authordeps --missing | cpanm -nq
    dzil listdeps --develop --missing | cpanm -nq
    dzil test --all      # runs t/ plus xt/ author tests
    dzil build           # produces the release tarball
    dzil install         # install from the working copy
```

Leave the direct-`prove` block (`.proverc` adds `-I t/lib -I lib`) — it is still valid for running individual `t/*.t` files during development.

- [ ] **Step 2: Update `AGENTS.md` "Author tests" section**

The "Author tests under `xt/`" section lists `xt/perlcritic.t`, `xt/perltidy.t`, `xt/examples.t`, `xt/version.t`, `xt/synopsis.t`. Replace it to reflect that perlcritic, perltidy, and synopsis now run as Dist::Zilla-generated `xt/author/` tests under `dzil test --all`, that `xt/version.t` is gone (version coherence is structural now), and that `xt/author/examples.t` remains the hand-written script runner. The replacement text:

```
Author tests run under `dzil test --all`. Dist::Zilla generates the
perlcritic, perltidy, synopsis, compile, version, POD-syntax, and
CPAN-changes tests from dist.ini plugins; `xt/author/examples.t` is a
hand-written test that runs every `examples/*.pl` script. Lint config
lives in `perlcriticrc` and `perltidyrc` at the repo root.
```

- [ ] **Step 3: Update `AGENTS.md` "Releasing" section**

The "Releasing" section currently says to bump `$VERSION` in all four module files. Replace that guidance: the version now lives in **one** place — the `version =` line in `dist.ini` — and `[OurPkgVersion]` injects it into every module at build. Also correct the description of `release.yml`: it now genuinely gates on the tag-vs-version check and runs `dzil test --all` before uploading. Replace the section body with:

```
Releases are automated by `.github/workflows/release.yml`, triggered by
pushing a `v*` tag. The workflow checks that the tag matches the
`version =` line in `dist.ini`, runs `dzil test --all`, builds the
tarball with `dzil build`, uploads it to CPAN, and publishes a GitHub
release.

To cut a release: bump the `version =` line in `dist.ini` (the single
source of truth — [OurPkgVersion] injects it into every module), add a
`Changelog` entry, commit, then `git tag vX.YYY && git push origin
vX.YYY`.

The `PAUSE_USER` and `PAUSE_PASSWORD` repository secrets must be
configured for the CPAN upload step.
```

- [ ] **Step 4: Fix the stale "Architecture" heading**

`AGENTS.md`'s Architecture section opens with "Three modules implement the system" — there are four (Cookbook was added in Phase 1). Change "Three modules" to "Four modules".

- [ ] **Step 5: Add the `Changelog` entry**

At the very top of `Changelog`, add a new stanza above the `0.601` line. Use the `{{$NEXT}}` token as the version line so `[NextRelease]` stamps the real version and date at build time:

```
{{$NEXT}}
  - migrate the build from ExtUtils::MakeMaker to Dist::Zilla
  - single-source $VERSION in dist.ini, injected into every module
  - generate README.md from POD; badges sourced from module POD
  - replace hand-written xt/ author tests with Dist::Zilla plugins
  - expand the linux CI matrix to Perl 5.12, 5.20, 5.30, and latest
  - add tag/version and test gates to the release workflow

```

(Keep one blank line between the new stanza and the existing `0.601` line.)

- [ ] **Step 6: Verify the build still passes with the Changelog token**

Run: `dzil build`
Expected: succeeds; in the built dist, `MooX-Role-Parameterized-0.700/Changelog` shows `0.700   <date>` where `{{$NEXT}}` was.

- [ ] **Step 7: Clean and commit**

```bash
rm -rf MooX-Role-Parameterized-0.700 MooX-Role-Parameterized-0.700.tar.gz .build
git add AGENTS.md Changelog
git commit -m "Phase 3: sync AGENTS.md and Changelog for the DZ build

Document the dzil-based build/test/release commands, the single
dist.ini version source, and the DZ-generated author tests; correct
the stale 'three modules' note. Add the Phase 3 Changelog stanza.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Final verification (after all tasks)

- [ ] `dzil build` succeeds; `grep 'our $VERSION' MooX-Role-Parameterized-0.700/lib/MooX/Role/Parameterized*/*.pm` (and the main module) shows `'0.700'` in all four modules.
- [ ] `dzil test --all` ends with all tests passing.
- [ ] The repo `README.md` opens with the seven badges then the SYNOPSIS.
- [ ] `git ls-files Makefile.PL MANIFEST` returns nothing (both untracked/removed).
- [ ] The built `MooX-Role-Parameterized-0.700/` contains `Makefile.PL`, `META.json`, `META.yml`, `MANIFEST`, and `xt/author/` tests.
- [ ] All four GitHub Actions YAML files parse cleanly.
- [ ] Clean up any build artifacts: `rm -rf MooX-Role-Parameterized-0.700* .build`.

Then use **superpowers:finishing-a-development-branch** to open the PR against `devel`. Do not push a `v0.700` tag until the PR is merged and the maintainer approves the release.
