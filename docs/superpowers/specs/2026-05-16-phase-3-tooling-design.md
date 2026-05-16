# Phase 3 — Tooling & Release Pipeline (Dist::Zilla migration)

- **Date:** 2026-05-16
- **Status:** Approved
- **Phase:** 3 of a 5-phase modernization roadmap for `MooX::Role::Parameterized`

## Context

`MooX::Role::Parameterized` is a CPAN distribution targeting Perl 5.012, built
with `ExtUtils::MakeMaker` and a hand-maintained `Makefile.PL`. Phases 0–2 are
released (latest: `v0.601`). The modernization roadmap:

| # | Phase | Status |
|---|---|---|
| 0 | Drive-by `0.5O1` typo bugfix | folded into `v0.502` |
| 1 | Documentation & posture | released (`v0.601`) |
| 2 | Bump min Perl to 5.12 + release automation | released (`v0.600`) |
| 3 | **Tooling & release pipeline** | this spec |
| 4 | Code modernization under the 5.12 floor (`//`, `state`, drop redundant `use strict;`, reconsider `our %INFO` and `goto &`) | future |
| 5 | Bump min Perl to 5.20+ and adopt signatures / postfix deref | future |

This spec covers Phase 3 only.

Phase 2 shipped a thinner pipeline than its own spec described: `release.yml`
has no version/tag gate and no test gates, and `linux.yml` runs only Perl
`5.12.2` + latest rather than the planned `5.12/5.20/5.30` matrix. Those dropped
pieces are folded into Phase 3.

## Goals

1. Replace `ExtUtils::MakeMaker` + hand-maintained `Makefile.PL` with
   Dist::Zilla as the build/authoring tool.
2. Single-source `$VERSION` from one place and inject it, identical, into all
   four packages at build time.
3. Auto-generate `README.md` from the main module's POD.
4. Modernize CI: broader `linux.yml` Perl matrix; convert `macos.yml` /
   `windows.yml`; harden `release.yml` with real gates.
5. Broaden the `xt/` author-test coverage.

## Non-goals (deferred)

- Pod::Weaver / auto-generating POD boilerplate — POD stays hand-written.
- Code modernization under 5.12 (`//`, `state`, dropping redundant
  `use strict;`) — Phase 4.
- Bumping the Perl floor — Phase 5.

## Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Build/authoring tool | Dist::Zilla | Per-package version injection from one source is DZ's wheelhouse; Minilla single-sources only the main module. |
| Plugin management | `[@Basic]` bundle + layered plugins | Maintainer choice; well-known starter set, adjusted where dated. |
| Version single-sourcing | `version =` in `dist.ini`; `[OurPkgVersion]` injects into every `# VERSION` marker | Every shipped package carries an explicit, identical version — no PAUSE indexing regression. |
| Release flow | CI-driven; DZ is build-tool only | Keeps Phase 2's tag-triggered `release.yml`; no PAUSE secrets leave GitHub; `dzil release` is not used. |
| `Makefile.PL` / `MANIFEST` | Deleted from git; generated into the tarball | Standard DZ practice; they become build artifacts. |
| Changelog filename | `Changelog` kept (not renamed to `Changes`) | Maintainer choice; `[NextRelease]` is configured with `filename = Changelog`. |
| README badges | Embedded in main module POD inside `=begin :markdown` | Survives every README regeneration; single source. |
| Author tests | DZ `[Test::*]` plugins replace the hand-written perlcritic/perltidy/synopsis tests; `xt/examples.t` kept hand-written | DZ plugins deliver broader coverage zero-config; `examples.t` has no DZ equivalent. |
| `xt/version.t` | Deleted | `[OurPkgVersion]` guarantees version coherence structurally. |

## Deliverables

### A. `dist.ini`

New tracked file at the repository root:

```ini
name    = MooX-Role-Parameterized
author  = Tiago Peczenyj <tiago.peczenyj+cpan@gmail.com>
license = MIT
copyright_holder = Tiago Peczenyj
version = 0.700

[@Basic]
[@Basic] / -remove = Readme        ; drop the plain-text README
[@Basic] / -remove = UploadToCPAN  ; CI uploads; dzil is build-only

[OurPkgVersion]                    ; injects $VERSION at every "# VERSION"
[MetaJSON]                         ; @Basic only ships META.yml
[MetaProvides::Package]            ; explicit, per-package provides
[MetaResources]
homepage   = https://github.com/peczenyj/MooX-Role-Parameterized
repository.type = git
repository.url  = https://github.com/peczenyj/MooX-Role-Parameterized.git
repository.web  = https://github.com/peczenyj/MooX-Role-Parameterized
bugtracker.web  = https://github.com/peczenyj/MooX-Role-Parameterized/issues

[NextRelease]
filename = Changelog

[ReadmeAnyFromPod]
type     = markdown
filename = README.md
location = root

[Prereqs]
perl            = 5.012
Carp            = 0
Module::Runtime = 0
Moo             = 2
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

[Test::Perl::Critic]
[Test::PerlTidy]
[Test::Synopsis]
[Test::Compile]
[Test::Version]
[PodSyntaxTests]
[Test::CPAN::Changes]
```

`x_authority => 'cpan:PACMAN'` (present in the current `Makefile.PL`
`META_MERGE`) is preserved via the `[Authority]` plugin —
`authority = cpan:PACMAN` — added to `dist.ini` alongside the block above.

**`[@Basic]` adjustments:** `[@Basic]` ships a plain-text `[Readme]` (superseded
by `[ReadmeAnyFromPod]`) and `[UploadToCPAN]` (only fires on `dzil release`,
which is unused — removed for clarity). `[@Basic]` emits only `META.yml`, so
`[MetaJSON]` is added.

### B. Version injection — module source changes

All four modules currently open with `package NAME 0.601;`. Each is rewritten
to a version-less package statement plus a `# VERSION` marker on its own line:

```perl
package MooX::Role::Parameterized;
# VERSION
use v5.12;
```

At `dzil build`, `[OurPkgVersion]` rewrites each `# VERSION` line to
`our $VERSION = '0.700';`, sourced from the single `dist.ini` `version =`
value. The repo working copy carries no literal version; the tarball carries
all four, identical.

Affected modules:
- `lib/MooX/Role/Parameterized.pm`
- `lib/MooX/Role/Parameterized/Mop.pm`
- `lib/MooX/Role/Parameterized/With.pm`
- `lib/MooX/Role/Parameterized/Cookbook.pm`

The existing `# ABSTRACT:` comment in each module is retained (DZ reads it).

### C. README generation and badges

`[ReadmeAnyFromPod]` generates `README.md` from `MooX::Role::Parameterized`'s
POD, written both into the build and back into the repo root (`location =
root`) so the GitHub repository page stays current.

The 8 status badges currently in `README.md` (Kwalitee, the three CI
workflows, Coveralls, license, CPAN version) are moved into the main module's
POD, immediately after `=head1 NAME`, inside a region:

```pod
=begin :markdown

[![Kwalitee](...)](...)
... 8 badges ...

=end :markdown
```

`Pod::Markdown` passes the region through verbatim, so every regeneration
carries the badges. Other POD formatters (e.g. MetaCPAN) skip the `:markdown`
region — acceptable, as MetaCPAN renders its own badges.

### D. File disposition

| File | Phase 3 fate |
|---|---|
| `dist.ini` | new, tracked |
| `Makefile.PL` | deleted from git — generated by `[MakeMaker]` into the tarball |
| `MANIFEST` | deleted from git — generated by `[Manifest]` |
| `Makefile.old` | deleted — stale leftover |
| `META.yml` / `META.json` | generated; remain untracked |
| `MANIFEST.SKIP` | kept; the `^xt/` line removed (author tests ship); `^docs/` kept |
| `README.md` | becomes a generated artifact (still tracked, refreshed on build) |
| 4 module files | `package NAME;` + `# VERSION`; badges added to the main module POD |
| `Changelog` | kept; `[NextRelease]` manages its `{{$NEXT}}` token |
| `xt/version.t` | deleted |
| `xt/perlcritic.t`, `xt/perltidy.t`, `xt/synopsis.t` | deleted — replaced by DZ `[Test::*]` plugins |
| `xt/examples.t` | kept; moved to `xt/author/examples.t` so `[ExtraTests]` ships it |

### E. CI modernization

With `Makefile.PL` gone from the repo, `cpanm --installdeps .` has no metadata
to read. All three OS workflows move to the Dist::Zilla idiom:

```yaml
- run: cpanm -nq Dist::Zilla
- run: dzil authordeps --missing | cpanm -nq
- run: dzil listdeps --missing | cpanm -nq
- run: dzil test --all
```

- **`linux.yml`** — matrix expands to Perl `5.12`, `5.20`, `5.30`, and latest.
  The coverage job stays on the latest, via `dzil cover -test -report
  Coveralls`.
- **`macos.yml` / `windows.yml`** — converted to the same DZ idiom; the Perl
  version each installs is unchanged.

### F. `release.yml` hardening

Rebuilt on Dist::Zilla, triggered by `on: push: tags: ['v*']`:

1. Checkout; set up Perl (latest); install Dist::Zilla, `authordeps`,
   `listdeps`, and `CPAN::Uploader`.
2. **Gate — tag vs. version:** extract `version =` from `dist.ini`, compare to
   the tag minus its leading `v`; abort on mismatch.
3. **Gate — tests:** `dzil test --all`.
4. **Build:** `dzil build`, producing `MooX-Role-Parameterized-<version>.tar.gz`.
5. **Upload to CPAN:** `cpan-upload` with the existing `PAUSE_USER` /
   `PAUSE_PASSWORD` repository secrets; the `if: env.PAUSE_USER != ''`
   fork-guard is retained.
6. **GitHub release:** `softprops/action-gh-release`, tarball attached,
   published immediately.

The Phase 2 spec's "all modules in sync" gate is obsolete — `[OurPkgVersion]`
guarantees it structurally.

### G. Author tests

- `xt/version.t` deleted (DZ guarantees coherence).
- `xt/perlcritic.t`, `xt/perltidy.t`, `xt/synopsis.t` deleted; replaced by the
  `[Test::Perl::Critic]`, `[Test::PerlTidy]`, `[Test::Synopsis]` plugins, which
  generate the equivalent `xt/author/*.t` and run under `dzil test --all`.
- `xt/examples.t` kept hand-written (runs the five `examples/*.pl` scripts; no
  DZ equivalent), relocated to `xt/author/examples.t`.
- Broader coverage added via `[Test::Compile]`, `[Test::Version]`,
  `[PodSyntaxTests]`, `[Test::CPAN::Changes]` — all zero-config.

### H. Sync `AGENTS.md`

`AGENTS.md` documents the build/test/release commands and currently describes
the `ExtUtils::MakeMaker` workflow. Phase 3 updates:

- "Common commands" — replace `perl Makefile.PL && make && make test` with the
  Dist::Zilla idiom (`dzil build`, `dzil test --all`, `dzil install`).
- "Author tests" — reflect that perlcritic/perltidy/synopsis now run as
  DZ-generated tests, and that `xt/version.t` is gone.
- "Releasing" — describe `dist.ini`'s single `version =` line as the one place
  to bump (no longer four module files); correct the line that wrongly claims
  `release.yml` already gates on version and tests (it now does, post-Phase 3).
- "Architecture" — the "Three modules" heading is already stale (there are
  four); correct it while editing.

## Affected files

**New (or newly tracked):**
- `dist.ini`
- `xt/author/examples.t` (relocated from `xt/examples.t`)
- `docs/superpowers/specs/2026-05-16-phase-3-tooling-design.md` (this file)

**Deleted from git:**
- `Makefile.PL`, `MANIFEST`, `Makefile.old`
- `xt/version.t`, `xt/perlcritic.t`, `xt/perltidy.t`, `xt/synopsis.t`

**Modified:**
- `MANIFEST.SKIP` — drop the `^xt/` line.
- `README.md` — becomes generated; badges sourced from POD.
- The four `lib/` modules — version-less `package` statement + `# VERSION`;
  badges added to the main module POD.
- `.github/workflows/linux.yml`, `macos.yml`, `windows.yml`, `release.yml`.
- `AGENTS.md`.
- `Changelog` — one Phase 3 entry.

## Release sequencing

Phase 3 is a single release. The implementation merges to `devel`, then a
`v0.700` tag triggers the hardened `release.yml`. `0.700` (minor bump) signals
a build-system change with no API change. The first run of the rebuilt
`release.yml` is the live test of the new pipeline.

## Verification

- `dzil build` succeeds; the four modules in the built tarball all carry an
  identical `$VERSION` equal to `dist.ini`'s `version =`.
- `dzil test --all` passes (`t/` plus the generated and hand-written author
  tests).
- The generated `README.md` contains the SYNOPSIS and all 8 badges.
- `linux.yml` passes on Perl 5.12, 5.20, 5.30, and latest.
- The `release.yml` version gate fails for a deliberately mismatched tag and
  succeeds for a correctly tagged release.
- `v0.700` appears on CPAN and as a published GitHub release with the tarball
  attached.

## Risks

- **Dist::Zilla is a heavy author-side dependency.** Every contributor and CI
  job installs Dist::Zilla plus ~15 plugins. Mitigated: end users are
  unaffected — the tarball ships a plain generated `Makefile.PL`.
- **`dzil test` runs against a built copy**, not `lib/` directly. `.proverc`
  (`-I t/lib -I lib`) still serves direct `prove` during development.
- **First `release.yml` run is the live test of the new pipeline** — a tooling
  misconfiguration surfaces at tag time. Mitigation: run `dzil build` and
  `dzil test --all` locally before tagging `v0.700`.
- **`MANIFEST.SKIP` interaction:** with DZ, MANIFEST is generated; the `^xt/`
  removal is required so author tests ship, but any other stale rule that
  conflicts with `[GatherDir]`/`[PruneCruft]` should be reviewed during
  implementation.
