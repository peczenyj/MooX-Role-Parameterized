# Phase 1 — Documentation & Posture

- **Date:** 2026-05-16
- **Status:** Approved
- **Phase:** 1 of a 5-phase modernization roadmap for `MooX::Role::Parameterized`

## Context

`MooX::Role::Parameterized` is a CPAN distribution being modernized in five
phases, each with its own spec → plan → implement cycle:

| # | Phase | Status |
|---|---|---|
| 0 | Drive-by `0.5O1` typo bugfix | folded into the min-Perl release `v0.502` (Phase 2) |
| 1 | **Documentation & posture** | this spec |
| 2 | Bump min Perl to 5.12 + release automation | done — released as `v0.502` and `v0.600` |
| 3 | Tooling & release pipeline (build system, single-source `$VERSION`, auto-README, modern CI, broader author tests) | future |
| 4 | Code modernization under the 5.12 floor (`//`, `state`, drop redundant `use strict;`, reconsider `our %INFO` and `goto &`) | future |
| 5 | Bump min Perl to 5.20+ and adopt signatures / postfix deref | future |

Phase 2 shipped the 5.12 floor and release automation but deliberately deferred
the project's *posture* — the "experimental" framing, the absence of a security
policy, the unreconciled branch layout — to this phase. Phase 1 also picks up a
documentation request raised by the maintainer during brainstorming: a
discoverable cookbook page. This spec covers Phase 1 only.

## Goals

1. Remove the "experimental" framing from the distribution's documentation.
2. Add a `SECURITY.md` vulnerability-reporting policy.
3. Reconcile the Git branch layout (branch model and stable-branch sync).
4. Add a `MooX::Role::Parameterized::Cookbook` documentation page.
5. Back every cookbook recipe with a runnable `examples/` script, verified by a
   new `xt/` author test.

## Non-goals (deferred to later phases)

- Crossing `1.0`. Dropping "experimental" is a wording change only; the
  distribution stays on `0.x` numbering. A deliberate `1.0` decision is left to
  a future phase.
- Tying a release to Phase 1. The changes here are documentation and repository
  hygiene; they ride along with the next functional release rather than
  triggering one of their own.
- Auto-generating `README.md` from POD (Phase 3).
- Moving reference content out of the main module POD into the cookbook. The
  cookbook is purely additive; `Parameterized.pm`'s POD is unchanged except for
  the two edits named in Deliverable A.
- Extracting and executing code blocks directly from cookbook POD. Phase 1
  verifies examples by running `examples/*.pl` scripts; POD-snippet extraction
  is tooling work left to Phase 3.

## Decisions

| Decision | Choice | Rationale |
|---|---|---|
| `1.0` release | Not now — stay `0.x` | Maintainer chose to decouple the maturity *wording* from the version *number*; crossing `1.0` is a separate, deliberate decision. |
| Phase 1 release | None | Maintainer chose Phase 1 to be documentation/hygiene only, with no dedicated release. |
| Branch model | Keep `master` (stable) + `devel` (integration) | Maintainer chose a two-branch git-flow over consolidating to a single branch. |
| Feature-branch pruning | None — all existing remote branches are left in place | Maintainer chose not to delete branches; deletion is irreversible and the stale branches are harmless. |
| Vulnerability reporting channel | Private email to `tiago.peczenyj+cpan@gmail.com` | Maintainer choice; the CPAN contact address, works independently of the hosting platform. |
| Cookbook structure | A single POD-only `::Cookbook` page, recipes as `=head1` sections | Maintainer chose this over a Moose-style index + per-recipe sub-modules; one file avoids multiplying `MANIFEST` and `provides` entries in a three-module distribution. |
| Cookbook version declaration | `package MooX::Role::Parameterized::Cookbook 0.600;` | Uses the `package NAME VERSION` syntax the other modules adopted under the 5.12 floor (commit `53208cb`). |
| Example verification | One runnable `examples/` script per recipe, run by an `xt/` author test | Maintainer chose tested examples so cookbook code cannot silently drift from working code. |

## Deliverables

### A. Drop the "experimental" framing

The word "experimental" appears in four places, each describing the same fact —
that this distribution is a port of `MooseX::Role::Parameterized` to `Moo`:

- `lib/MooX/Role/Parameterized.pm:238` — `=head1 DESCRIPTION`
- `lib/MooX/Role/Parameterized/With.pm:58`
- `README.md:65` — mirrors the `Parameterized.pm` DESCRIPTION
- `AGENTS.md:7`

Each is reworded to drop "experimental" while keeping the accurate "port of
`MooseX::Role::Parameterized` to `Moo`" description. No `$VERSION` change.

While editing `Parameterized.pm`'s POD, the adjacent `=head1 STATIC METHOS`
typo (line 301) is corrected to `STATIC METHODS`.

`README.md` is hand-edited to match the POD; auto-generating it from POD is
Phase 3 work.

### B. `SECURITY.md`

A new repository-root `SECURITY.md` in the GitHub-recognized format:

- **Supported Versions** — a short statement that only the latest CPAN release
  receives security fixes.
- **Reporting a Vulnerability** — directs reporters to email
  `tiago.peczenyj+cpan@gmail.com` privately rather than opening a public issue,
  and sets a good-faith acknowledgement expectation.

`SECURITY.md` matches no `MANIFEST.SKIP` rule, so `make manifest` adds it to
`MANIFEST` and it ships in the CPAN tarball alongside the existing governance
docs `CONTRIBUTING`, `CODE_OF_CONDUCT.md`, and `AGENTS.md`. This is consistent
with how those files are already handled and needs no special treatment. Having
no `.pod` extension, it is not installed as a man page.

### C. Branch reconciliation

The remote currently carries `master` and `devel` plus several feature
branches. `origin/HEAD` points at `devel`, which is one commit ahead of
`master`.

- **Branch model:** keep both `master` and `devel`. `master` is the
  stable/released branch; `devel` is the integration branch. `origin/HEAD`
  stays `devel`.
- **Sync `master`:** fast-forward `master` to the `v0.600` release state so the
  stable branch reflects the current CPAN release.
- **Feature branches:** left in place. No branches are deleted in Phase 1 —
  deletion is irreversible and the stale branches cause no harm.
- **README badges:** the coverage badge (`branch=master`) and the `LICENSE`
  link (`blob/master/`) already target `master`. Keeping `master` means they
  remain correct — no badge changes are needed.

### D. `MooX::Role::Parameterized::Cookbook`

A new POD-only module — `package MooX::Role::Parameterized::Cookbook 0.600;`
followed by `1;`, containing no executable code. Recipes are `=head1` sections
within the single file:

1. **Basics** — writing your first parameterized role (the `Counter` synopsis).
2. **Parameters** — `required`, typed, and default parameters.
3. **Applying roles** — `MooX::Role::Parameterized::With`, including multiple
   and arrayref parameter sets.
4. **Porting from `MooseX::Role::Parameterized`** — the differences a Moose user
   needs to know.
5. **A worked example** — a complete, non-trivial program (the Perl Weekly
   Challenge task).

Wiring:

- Added to `MANIFEST` so it ships in the tarball.
- Added to the `%provides` loop's file list in `Makefile.PL` so the META
  `provides` map stays complete (kwalitee `meta_yml_has_provides`).
- Linked from `Parameterized.pm`'s `=head1 SEE ALSO`.

The `$VERSION` literal `0.600` matches the current release of the three
existing modules and is declared with the `package NAME VERSION` syntax those
modules adopted under the 5.12 floor — `package MooX::Role::Parameterized::Cookbook 0.600;`.
This is consistent with the per-file versioning the distribution uses today
(single-sourcing `$VERSION` is Phase 3).

### E. Tested examples (`xt/`)

Every cookbook recipe is backed by a runnable script in `examples/`, and a new
author test runs them all so the cookbook cannot drift from working code.

`examples/` currently holds three scripts:

- `parameters.pl` — recipe 2 (Parameters)
- `moosex-role-parameterized.pl` — recipe 4 (Porting from MooseX)
- `task-1-weekly-challenge-122.pl` — recipe 5 (A worked example)

Two scripts are added so all five recipes have a backing script:

- `examples/basics.pl` for recipe 1 (the `Counter` parameterized role);
- `examples/applying-roles.pl` for recipe 3 (`MooX::Role::Parameterized::With`,
  including multiple/arrayref parameter sets).

`examples/task-1-weekly-challenge-122.pl` currently ends in an unbounded
`while (1) { ...; sleep 1 }` loop, so it would never return. It is modified to
stop after a fixed number of iterations and to drop the `sleep`, so the author
test can run it to completion while it remains a valid demonstration.

Both new scripts follow the existing `examples/` conventions, including the
`use v5.12;` declaration established in Phase 2, and are added to `MANIFEST`.

A new `xt/` author test — `xt/author/examples.t` — runs each `examples/*.pl`
script in a child process and asserts a clean (zero) exit. It is glob-driven so
future scripts are picked up automatically. Per the existing `MANIFEST.SKIP`
rule `^xt/`, it is excluded from the CPAN tarball, consistent with the Phase 2
`xt/author/perlcritic.t` and `xt/author/perltidy.t` tests.

The cookbook recipes reference their backing `examples/` script by name so a
reader can run the full program.

## Affected files

**New:**
- `SECURITY.md` — vulnerability-reporting policy (Deliverable B).
- `lib/MooX/Role/Parameterized/Cookbook.pm` — POD-only cookbook (Deliverable D).
- `examples/basics.pl` — recipe 1 backing script (Deliverable E).
- `examples/applying-roles.pl` — recipe 3 backing script (Deliverable E).
- `xt/author/examples.t` — runs the example scripts (Deliverable E).
- `docs/superpowers/specs/2026-05-16-phase-1-docs-posture-design.md` (this file).

**Modified:**
- `lib/MooX/Role/Parameterized.pm` — reword DESCRIPTION; fix `STATIC METHOS`
  typo; add the cookbook to `SEE ALSO`.
- `lib/MooX/Role/Parameterized/With.pm` — reword the experimental sentence.
- `README.md` — reword the experimental sentence to match the POD.
- `AGENTS.md` — reword the experimental sentence; note `SECURITY.md` and the
  cookbook where the document describes project layout/posture.
- `Makefile.PL` — add `Cookbook.pm` to the `%provides` file list.
- `examples/task-1-weekly-challenge-122.pl` — bound the `while (1)` loop and
  drop the `sleep` so the author test can run it to completion.
- `MANIFEST` — gains `SECURITY.md`, `Cookbook.pm`, and the two new
  `examples/` scripts (`make manifest` regenerates it).
- `Changelog` — an entry recording the Phase 1 documentation changes.

The new `xt/` file and the `docs/` spec are excluded from the tarball by the
existing `MANIFEST.SKIP` rules `^xt/` and `^docs/`.

## Verification

- `perl Makefile.PL && make && make test` passes.
- `prove -lr t` passes.
- `prove -l xt/` passes — including the new `xt/author/examples.t`, which runs
  all five `examples/*.pl` scripts to a clean exit.
- `perl -c lib/MooX/Role/Parameterized/Cookbook.pm` compiles; `podchecker`
  reports no POD errors for it.
- The generated `MYMETA.yml`/`MYMETA.json` `provides` map lists
  `MooX::Role::Parameterized::Cookbook`.
- No occurrence of "experimental" remains in `lib/`, `README.md`, or
  `AGENTS.md` (`grep -ri experimental`).
- `SECURITY.md` is present at the repository root and listed in `MANIFEST`.
- `master` resolves to the `v0.600` release state; `devel` remains
  `origin/HEAD`; no branches were deleted.

## Risks

- **The cookbook duplicates code that lives in `examples/` and the synopsis.**
  The `xt/author/examples.t` test bounds this risk for the scripts; the
  in-POD code blocks still rely on the maintainer keeping them aligned with the
  scripts they reference. POD-snippet extraction (Phase 3) would close the gap
  fully.
- **A new POD-only module adds a `provides` entry and a `MANIFEST` line.** This
  is handled in Deliverable D; it is noted here because the same surface was
  the subject of recent kwalitee fixes and must not regress.
