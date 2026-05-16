# AGENTS.md

This file provides guidance to agentic coding tools when working with code in this repository.

## Project

`MooX::Role::Parameterized` is a CPAN distribution: a port of `MooseX::Role::Parameterized` to `Moo`. It lets a Moo role accept composition-time parameters that customize what gets injected into the consumer (attributes, methods, modifiers).

Minimum Perl is 5.12 (CI matrix runs Perl 5.12 and the latest stable). Patches must be submitted against the `devel` branch.

Security vulnerabilities should be reported privately as described in `SECURITY.md`, not through public issues.

## Common commands

Build / test (ExtUtils::MakeMaker):

```
perl Makefile.PL
make
make test
```

Run the test suite directly with prove (`.proverc` already adds `-I t/lib -I lib`):

```
prove -v                     # all tests
prove -v t/02_basic.t        # single file
prove -lr t                  # how CI invokes it
```

Coverage (CI runs this on the latest-Perl job):

```
cpanm -n Devel::Cover Devel::Cover::Report::Coveralls
cover -test -report Coveralls
```

Author tests under `xt/`, all run in CI on the latest-Perl job via `prove -lr xt`:

```
prove -l xt/perlcritic.t   # Perl::Critic over lib/
prove -l xt/perltidy.t     # perltidy formatting check
prove -l xt/examples.t     # run every examples/*.pl script
prove -lr xt               # all of them at once
```

`xt/` author tests are not run by `make test`. Install their dependencies with `cpanm --with-develop --installdeps .`.

Install dev dependencies:

```
curl -L https://cpanmin.us | perl - --installdeps --with-develop .
```

## Architecture

Three modules implement the system; understanding how they cooperate is the bulk of the codebase:

### `lib/MooX/Role/Parameterized.pm` — the DSL and registry
- Exports `parameter`, `role`, `apply`, `apply_roles_to_target`.
- All per-role state lives in the package-global `%INFO`, keyed by role package name. Each entry holds `is_role`, the `code_for` block passed to `role { ... }`, and either a list of `parameters_definition` or a lazily-built `parameter_definition_klass`.
- `role { ... }` may only be called once per package; calling twice croaks.
- `parameter NAME => (...)` stashes a `Moo::has`-style spec. On first apply, `_create_parameters_klass` synthesizes an anonymous Moo class (`<Role>::__MOOX_ROLE_PARAMETERIZED_PARAMS__`) via `MooX::BuildClass` and uses it to bless+validate every params hash thereafter (this is what enforces `required`, `isa`, `default`).
- `apply_roles_to_target` is the real entry point: it runs the role's code block once per params hashref (an arrayref means "apply N times with N parameter sets"), then finishes by calling `Moo::Role->apply_roles_to_package`.
- `build_apply_roles_to_package($orig)` returns the closure that `::With` installs as the caller's `with`. Order of dispatch: parameterized role → fall back to `$orig` (the consumer's pre-existing `with`, e.g. Moo's) → fall back to `Moo::Role->apply_roles_to_package` → croak. This is how Moo, Moo::Role, and Role::Tiny roles all keep working alongside parameterized ones.

### `lib/MooX/Role/Parameterized/Mop.pm` — proxy passed into the role block
- The `$mop` second argument to `role { my ($p, $mop) = @_; ... }`. Holds only `target` (consumer package) and `role` (defining package).
- `has`, `with`, `before`, `around`, `after` `goto` the corresponding sub installed in the **target** package — this is the whole point: it sidesteps the trap where calling `has` directly inside the role body would install on the role instead of the consumer.
- `requires` `goto`s into the **role** package, not the target.
- `method($name, $code)` installs by glob assignment (`*{ "${target}::${name}" } = $code`); when `$MooX::Role::Parameterized::VERBOSE` is true it carps before overriding an existing method.

### `lib/MooX/Role/Parameterized/With.pm` — `with` override
- `use MooX::Role::Parameterized::With;` overrides the caller's `with` at import time, capturing the previous `with` (if any) as the fallback `$orig` described above. Consumers can then write `with RoleName => { params }` or `with RoleName => [ {...}, {...} ]`, mixed with plain Moo/Role::Tiny role names in the same call.

### `$VERBOSE` flag
`$MooX::Role::Parameterized::VERBOSE` (default false) controls non-fatal warnings (method override, `apply` deprecation carp, redefining `with`). Tests rely on the silent default — flipping it on may add unexpected output.

### `lib/MooX/Role/Parameterized/Cookbook.pm` — documentation only
POD-only module: five recipes with worked examples, no functional code (just the `package`/`use`/`1;` boilerplate before `__END__`). Each recipe is backed by a script in `examples/`, and `xt/examples.t` runs them all.

## Releasing

Releases are automated by `.github/workflows/release.yml`, triggered by pushing a `v*` tag. The workflow checks that the tag matches `$VERSION` in all three modules, runs the test and author-test suites, builds the tarball, uploads it to CPAN, and publishes a GitHub release.

To cut a release: bump `$VERSION` in **all three** module files, add a `Changelog` entry, commit, then `git tag vX.YYY && git push origin vX.YYY`.

- `lib/MooX/Role/Parameterized.pm`
- `lib/MooX/Role/Parameterized/Mop.pm`
- `lib/MooX/Role/Parameterized/With.pm`

The `PAUSE_USERNAME` and `PAUSE_PASSWORD` repository secrets must be configured for the CPAN upload step.
