# Phase 1 — Documentation & Posture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the "experimental" framing from `MooX::Role::Parameterized`, add a `SECURITY.md` policy, reconcile the Git branch layout, and add a `MooX::Role::Parameterized::Cookbook` documentation page backed by runnable, tested example scripts.

**Architecture:** Phase 1 is documentation and repository hygiene — no functional code changes. Edits touch POD, Markdown, one new POD-only module, two new example scripts, one bounded example script, one new author test, and `Makefile.PL`/`MANIFEST`/`Changelog` metadata. Every cookbook recipe is backed by a script under `examples/`, and a new `xt/author/examples.t` runs all of them so the documentation cannot silently drift from working code.

**Tech Stack:** Perl 5.12, `Moo`, `MooX::Role::Parameterized`, `ExtUtils::MakeMaker`, POD, `Test::More`, author tests under `xt/` (`Test::Perl::Critic`, `Test::PerlTidy`).

**Spec:** `docs/superpowers/specs/2026-05-16-phase-1-docs-posture-design.md`

---

## Conventions for every task

- **Commit messages** follow the repository style: a capitalized sentence, no `feat:`/`docs:` prefix. End every commit message with:

  ```
  Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
  ```

- **Author tests** are run with `prove -l xt/author/<name>.t`. They need their dependencies installed once: `cpanm --with-develop --installdeps .`.
- The full test suite is run with `prove -lr t` (the `.proverc` adds `-I t/lib -I lib`).
- If `prove -l xt/author/perltidy.t` fails for a file this plan creates or edits, reformat it in place with `perltidy --profile=.perltidyrc -b -bext='/' <file>` and re-run the test.

---

## Task 0: Create the working branch

**Files:** none (Git only).

- [ ] **Step 1: Confirm a clean tree on `devel`**

Run: `git status --short && git branch --show-current`
Expected: no output from `git status`; current branch is `devel`.

- [ ] **Step 2: Create and switch to the feature branch**

```bash
git checkout -b feature/phase-1-docs-posture
```

Expected: `Switched to a new branch 'feature/phase-1-docs-posture'`.

All implementation tasks (1–8) commit to this branch. Task 9 (branch reconciliation) operates on `master` and is independent.

---

## Task 1: Drop the "experimental" framing

**Files:**
- Modify: `lib/MooX/Role/Parameterized.pm:238` and `:301`
- Modify: `lib/MooX/Role/Parameterized/With.pm:58`
- Modify: `README.md:65`
- Modify: `AGENTS.md:7`

- [ ] **Step 1: Reword the `Parameterized.pm` DESCRIPTION**

In `lib/MooX/Role/Parameterized.pm`, replace:

```
It is an B<experimental> port of L<MooseX::Role::Parameterized> to L<Moo>.
```

with:

```
It is a port of L<MooseX::Role::Parameterized> to L<Moo>.
```

- [ ] **Step 2: Fix the `STATIC METHOS` heading typo**

In the same file, replace:

```
=head1 STATIC METHOS
```

with:

```
=head1 STATIC METHODS
```

- [ ] **Step 3: Reword the `With.pm` DESCRIPTION**

In `lib/MooX/Role/Parameterized/With.pm`, replace:

```
This B<experimental> package try to offer an easy way to add parametrized roles.
```

with:

```
This package tries to offer an easy way to add parameterized roles.
```

- [ ] **Step 4: Reword the `README.md` DESCRIPTION**

In `README.md`, replace:

```
It is an **experimental** port of [MooseX::Role::Parameterized](https://metacpan.org/pod/MooseX::Role::Parameterized) to [Moo](https://metacpan.org/pod/Moo).
```

with:

```
It is a port of [MooseX::Role::Parameterized](https://metacpan.org/pod/MooseX::Role::Parameterized) to [Moo](https://metacpan.org/pod/Moo).
```

- [ ] **Step 5: Reword the `AGENTS.md` Project section**

In `AGENTS.md`, replace:

```
`MooX::Role::Parameterized` is a CPAN distribution: an experimental port of `MooseX::Role::Parameterized` to `Moo`. It lets a Moo role accept composition-time parameters that customize what gets injected into the consumer (attributes, methods, modifiers).
```

with:

```
`MooX::Role::Parameterized` is a CPAN distribution: a port of `MooseX::Role::Parameterized` to `Moo`. It lets a Moo role accept composition-time parameters that customize what gets injected into the consumer (attributes, methods, modifiers).
```

- [ ] **Step 6: Verify no "experimental" framing remains**

Run: `grep -rin experimental lib/ README.md AGENTS.md`
Expected: no output. (If `lib/` reports anything, it is a miss — fix it.)

- [ ] **Step 7: Verify the POD still parses and tests pass**

Run: `prove -lr t`
Expected: all test files pass, including `t/99-pod.t`.

- [ ] **Step 8: Commit**

```bash
git add lib/MooX/Role/Parameterized.pm lib/MooX/Role/Parameterized/With.pm README.md AGENTS.md
git commit -m "$(cat <<'EOF'
Drop the "experimental" framing from the documentation

The distribution is a stable port of MooseX::Role::Parameterized; the
"experimental" wording no longer reflects its maturity. This is a
wording change only — the distribution stays on 0.x numbering. Also
fixes the adjacent "STATIC METHOS" heading typo.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: Add `SECURITY.md`

**Files:**
- Create: `SECURITY.md`
- Modify: `MANIFEST`

- [ ] **Step 1: Create `SECURITY.md`**

Create `SECURITY.md` at the repository root with exactly this content:

```markdown
# Security Policy

## Supported Versions

Only the latest release of `MooX-Role-Parameterized` published on
[CPAN](https://metacpan.org/dist/MooX-Role-Parameterized) receives security
fixes. Older releases are not maintained.

## Reporting a Vulnerability

Please report security vulnerabilities **privately**. Do not open a public
GitHub issue for a security problem.

Email the maintainer at **tiago.peczenyj+cpan@gmail.com** with:

- a description of the vulnerability,
- steps to reproduce it, and
- the affected version(s).

You can expect an acknowledgement within a few days. Once the issue is
confirmed, a fixed release is published to CPAN and the change recorded in the
`Changelog`.
```

- [ ] **Step 2: Add `SECURITY.md` to `MANIFEST`**

In `MANIFEST`, the entry `README.md` is immediately followed by `t/01_load.t`. Insert `SECURITY.md` between them, so that region reads:

```
README.md
SECURITY.md
t/01_load.t
```

- [ ] **Step 3: Verify `SECURITY.md` is listed in `MANIFEST`**

Run: `grep -nx 'SECURITY.md' MANIFEST`
Expected: one matching line — `SECURITY.md` is present in `MANIFEST`.

- [ ] **Step 4: Commit**

```bash
git add SECURITY.md MANIFEST
git commit -m "$(cat <<'EOF'
Add SECURITY.md vulnerability-reporting policy

Vulnerabilities are reported privately by email to the maintainer
rather than through public issues. The file ships in the tarball
alongside the other governance docs.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: Add the `MooX::Role::Parameterized::Cookbook` module

**Files:**
- Create: `lib/MooX/Role/Parameterized/Cookbook.pm`
- Modify: `MANIFEST`
- Modify: `Makefile.PL`
- Modify: `lib/MooX/Role/Parameterized.pm` (SEE ALSO)

- [ ] **Step 1: Create `lib/MooX/Role/Parameterized/Cookbook.pm`**

Create the file with exactly this content:

```perl
package MooX::Role::Parameterized::Cookbook 0.600;

use v5.12;
use strict;
use warnings;

# ABSTRACT: recipes and worked examples for MooX::Role::Parameterized

1;

__END__

=head1 NAME

MooX::Role::Parameterized::Cookbook - recipes for parameterized roles with Moo

=head1 DESCRIPTION

This is a documentation-only module. It collects worked recipes for
L<MooX::Role::Parameterized>, the L<Moo> port of
L<MooseX::Role::Parameterized>.

Each recipe is backed by a runnable script in the distribution's F<examples/>
directory, named at the end of the recipe. The author test
F<xt/author/examples.t> runs every one of those scripts, so the code shown here
is kept honest against working programs.

If you have never used a parameterized role before, read the recipes in order.
If you are porting code from Moose, jump to
L</"RECIPE 4: PORTING FROM MooseX::Role::Parameterized">.

=head1 RECIPE 1: YOUR FIRST PARAMETERIZED ROLE

B<Problem:> you want a role that injects an attribute and a couple of methods,
but the names depend on how the role is consumed.

B<Solution:> declare a C<parameter>, then build the role body from it.

    package Counter;

    use Moo::Role;
    use MooX::Role::Parameterized;

    parameter name => (
        is       => 'ro',
        required => 1,
    );

    role {
        my ( $params, $mop ) = @_;

        my $name = $params->name;

        $mop->has( $name => ( is => 'rw', default => sub {0} ) );

        $mop->method(
            "increment_$name" => sub {
                my $self = shift;
                $self->$name( $self->$name + 1 );
            }
        );

        $mop->method(
            "reset_$name" => sub {
                my $self = shift;
                $self->$name(0);
            }
        );
    };

Consume it with L<MooX::Role::Parameterized::With>, passing the parameter:

    package Game::Wand;

    use Moo;
    use MooX::Role::Parameterized::With;

    with Counter => { name => 'zapped' };

C<Game::Wand> now has a C<zapped> attribute plus C<increment_zapped> and
C<reset_zapped> methods.

Two things to remember:

=over

=item *

C<parameter> takes the same options as C<Moo::has> — C<is> is mandatory.

=item *

Inside the C<role> block, always go through the C<$mop> proxy
(C<< $mop->has >>, C<< $mop->method >>). Calling C<has> directly would install
on the role instead of the consumer.

=back

B<Runnable example:> F<examples/basics.pl>.

=head1 RECIPE 2: REQUIRED, TYPED, AND OPTIONAL PARAMETERS

B<Problem:> you want some parameters mandatory, some optional, and some
validated.

B<Solution:> C<parameter> accepts the full C<Moo::has> specification, including
C<required>, C<isa>, C<default>, and C<predicate>.

    package Field;

    use Moo::Role;
    use MooX::Role::Parameterized;

    parameter mandatory_attribute => (
        is       => 'ro',
        required => 1,
    );

    parameter optional_attribute => (
        is        => 'ro',
        predicate => 1,
    );

    role {
        my ( $params, $mop ) = @_;

        $mop->has( $params->mandatory_attribute => ( is => 'rw' ) );

        if ( $params->has_optional_attribute ) {
            $mop->has( $params->optional_attribute => ( is => 'rw' ) );
        }
    };

When a role declares at least one C<parameter>, the C<$params> argument is
blessed into a generated L<Moo> class. That is what enforces C<required> and
C<isa>, and what gives you accessors such as C<< $params->mandatory_attribute >>
and the C<predicate> C<< $params->has_optional_attribute >>.

A role with no C<parameter> declarations still works — there C<$params> is a
plain hash reference.

B<Runnable example:> F<examples/parameters.pl>.

=head1 RECIPE 3: APPLYING A ROLE SEVERAL TIMES

B<Problem:> you want to apply the same parameterized role more than once to a
single consumer, each time with different parameters.

B<Solution:> pass an array reference of parameter sets. The C<with> installed
by L<MooX::Role::Parameterized::With> applies the role once per set.

    package KeyValue;

    use Moo::Role;
    use MooX::Role::Parameterized;

    parameter attr   => ( is => 'ro', required => 1 );
    parameter method => ( is => 'ro', required => 1 );

    role {
        my ( $params, $mop ) = @_;

        $mop->has( $params->attr => ( is => 'rw' ) );
        $mop->method( $params->method => sub {1024} );
    };

    package Widget;

    use Moo;
    use MooX::Role::Parameterized::With;

    with KeyValue => [
        { attr => 'width',  method => 'compute_width' },
        { attr => 'height', method => 'compute_height' },
      ],
      KeyValue => { attr => 'depth', method => 'compute_depth' };

C<Widget> ends up with C<width>, C<height>, and C<depth> attributes and the
three C<compute_*> methods. A single C<with> call can mix the arrayref and
hashref forms, and can name plain C<Moo>, C<Moo::Role>, and C<Role::Tiny> roles
alongside parameterized ones.

B<Runnable example:> F<examples/applying-roles.pl>.

=head1 RECIPE 4: PORTING FROM MooseX::Role::Parameterized

B<Problem:> you have a role written with L<MooseX::Role::Parameterized> and
want to move it to L<Moo>.

B<Solution:> the DSL is deliberately close. The differences that matter:

=over

=item *

Use C<use MooX::Role::Parameterized;> in the role and
C<use MooX::Role::Parameterized::With;> in the consumer.

=item *

C<parameter> options follow C<Moo::has>, so C<is> is mandatory — Moose lets you
omit it.

=item *

The C<role> block receives C<< ($params, $mop) >>. Build the role through the
C<$mop> proxy: C<< $mop->has >>, C<< $mop->method >>, C<< $mop->before >>,
C<< $mop->after >>, C<< $mop->around >>, C<< $mop->with >>, and
C<< $mop->requires >>.

=item *

There is no C<make_immutable> step to worry about.

=back

A Moose-style C<Counter> role and its C<Moo> equivalent sit side by side in the
runnable example so you can compare them directly.

B<Runnable example:> F<examples/moosex-role-parameterized.pl>.

=head1 RECIPE 5: A WORKED EXAMPLE — AN ARITHMETIC STREAM

B<Problem:> something larger than a snippet — a parameterized role used as a
building block in a small program.

B<Solution:> build a lazy arithmetic-sequence stream. A plain C<Stream> role
defines the C<next> protocol; a parameterized C<Stream::Sequence::Arithmetic>
role fills in C<first> and C<code> from its parameters.

    package Stream::Sequence::Arithmetic;

    use Moo::Role;
    use MooX::Role::Parameterized;
    with 'Stream';

    role {
        my ( $params, $mop ) = @_;

        $mop->has( state => ( is => 'rw', predicate => 1 ) );
        $mop->method( first => sub { $params->{first} } );
        $mop->method(
            code => sub {
                my ( $self, $previous ) = @_;
                return $previous + $params->{difference};
            }
        );
    };

    package Stream::TenPlusTen;

    use Moo;
    use MooX::Role::Parameterized::With;
    with 'Stream::Sequence::Arithmetic' => { first => 10, difference => 10 };

This role declares no C<parameter>, so C<$params> is a plain hash reference —
hence C<< $params->{first} >> rather than C<< $params->first >> (see Recipe 2).
C<Stream::TenPlusTen> yields 10, 20, 30, ...; the parameters C<first> and
C<difference> decide which arithmetic sequence you get. The full program
computes a running average over the first several terms.

This recipe is adapted from Perl Weekly Challenge 122.

B<Runnable example:> F<examples/task-1-weekly-challenge-122.pl>.

=head1 SEE ALSO

L<MooX::Role::Parameterized> - the DSL itself

L<MooX::Role::Parameterized::With> - the C<with> override used by consumers

L<MooseX::Role::Parameterized> - the Moose original

=head1 AUTHOR

Tiago Peczenyj <tiago.peczenyj+cpan@gmail.com>
```

- [ ] **Step 2: Verify the module compiles and its POD is valid**

Run: `perl -Ilib -c lib/MooX/Role/Parameterized/Cookbook.pm && podchecker lib/MooX/Role/Parameterized/Cookbook.pm`
Expected: `lib/MooX/Role/Parameterized/Cookbook.pm syntax OK` and `pod syntax OK`.

- [ ] **Step 3: Add `Cookbook.pm` to `MANIFEST`**

In `MANIFEST`, the entry `lib/MooX/Role/Parameterized.pm` is followed by `lib/MooX/Role/Parameterized/Mop.pm`. Insert the cookbook between them:

```
lib/MooX/Role/Parameterized.pm
lib/MooX/Role/Parameterized/Cookbook.pm
lib/MooX/Role/Parameterized/Mop.pm
lib/MooX/Role/Parameterized/With.pm
```

- [ ] **Step 4: Add `Cookbook.pm` to the `Makefile.PL` `%provides` list**

In `Makefile.PL`, replace this `for` list:

```perl
for my $file (
    'lib/MooX/Role/Parameterized.pm',
    'lib/MooX/Role/Parameterized/Mop.pm',
    'lib/MooX/Role/Parameterized/With.pm',
) {
```

with:

```perl
for my $file (
    'lib/MooX/Role/Parameterized.pm',
    'lib/MooX/Role/Parameterized/Cookbook.pm',
    'lib/MooX/Role/Parameterized/Mop.pm',
    'lib/MooX/Role/Parameterized/With.pm',
) {
```

- [ ] **Step 5: Link the cookbook from `Parameterized.pm`'s SEE ALSO**

In `lib/MooX/Role/Parameterized.pm`, replace:

```
=head1 SEE ALSO

L<MooseX::Role::Parameterized> - Moose version
```

with:

```
=head1 SEE ALSO

L<MooseX::Role::Parameterized> - Moose version

L<MooX::Role::Parameterized::Cookbook> - recipes and worked examples
```

- [ ] **Step 6: Verify the META `provides` map lists the cookbook**

Run: `perl Makefile.PL >/dev/null && grep -A2 'Cookbook' MYMETA.yml`
Expected: a `provides` block showing `MooX::Role::Parameterized::Cookbook` with `file: lib/MooX/Role/Parameterized/Cookbook.pm` and `version: '0.600'`. The generated `Makefile`, `MYMETA.*`, and `pm_to_blib` are gitignored build artifacts — leave them in place; they are never committed.

- [ ] **Step 7: Verify author tests and the test suite pass**

Run: `prove -l xt/author/perlcritic.t xt/author/perltidy.t && prove -lr t`
Expected: all pass. `perlcritic.t` critiques `lib/` including the new module; `perltidy.t` checks its formatting; `t/99-pod.t` validates its POD.

- [ ] **Step 8: Commit**

```bash
git add lib/MooX/Role/Parameterized/Cookbook.pm lib/MooX/Role/Parameterized.pm MANIFEST Makefile.PL
git commit -m "$(cat <<'EOF'
Add MooX::Role::Parameterized::Cookbook documentation page

A POD-only module collecting five recipes for parameterized roles,
each backed by a runnable examples/ script. Registered in MANIFEST and
in the Makefile.PL provides map, and linked from the main module's
SEE ALSO.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

---

## Task 4: Add the `examples/basics.pl` and `examples/applying-roles.pl` scripts

**Files:**
- Create: `examples/basics.pl`
- Create: `examples/applying-roles.pl`
- Modify: `MANIFEST`

- [ ] **Step 1: Create `examples/basics.pl`**

Create the file with exactly this content (the Recipe 1 program):

```perl
use v5.12;
use strict;
use warnings;

package Counter;

use Moo::Role;
use MooX::Role::Parameterized;

parameter name => (
    is       => 'ro',
    required => 1,
);

role {
    my ( $params, $mop ) = @_;

    my $name = $params->name;

    $mop->has( $name => ( is => 'rw', default => sub {0} ) );

    $mop->method(
        "increment_$name" => sub {
            my $self = shift;
            $self->$name( $self->$name + 1 );
        }
    );

    $mop->method(
        "reset_$name" => sub {
            my $self = shift;
            $self->$name(0);
        }
    );
};

package Game::Wand;

use Moo;
use MooX::Role::Parameterized::With;

with Counter => { name => 'zapped' };

package main;
use feature 'say';

my $wand = Game::Wand->new;

say 'zapped starts at ',      $wand->zapped;
$wand->increment_zapped for 1 .. 3;
say 'after 3 increments: ',   $wand->zapped;
$wand->reset_zapped;
say 'after reset: ',          $wand->zapped;
```

- [ ] **Step 2: Run `examples/basics.pl` and confirm it terminates**

Run: `perl -Ilib examples/basics.pl`
Expected output:

```
zapped starts at 0
after 3 increments: 3
after reset: 0
```

- [ ] **Step 3: Create `examples/applying-roles.pl`**

Create the file with exactly this content (the Recipe 3 program):

```perl
use v5.12;
use strict;
use warnings;

package KeyValue;

use Moo::Role;
use MooX::Role::Parameterized;

parameter attr   => ( is => 'ro', required => 1 );
parameter method => ( is => 'ro', required => 1 );

role {
    my ( $params, $mop ) = @_;

    $mop->has( $params->attr => ( is => 'rw' ) );
    $mop->method( $params->method => sub {1024} );
};

package Widget;

use Moo;
use MooX::Role::Parameterized::With;

with KeyValue => [
    { attr => 'width',  method => 'compute_width' },
    { attr => 'height', method => 'compute_height' },
  ],
  KeyValue => { attr => 'depth', method => 'compute_depth' };

has name => ( is => 'ro' );

package main;
use feature 'say';

my $widget = Widget->new(
    name   => 'box',
    width  => 10,
    height => 20,
    depth  => 30,
);

say 'name:   ', $widget->name;
say 'width:  ', $widget->width;
say 'height: ', $widget->height;
say 'depth:  ', $widget->depth;
say 'compute_width  => ', $widget->compute_width;
say 'compute_height => ', $widget->compute_height;
say 'compute_depth  => ', $widget->compute_depth;
```

- [ ] **Step 4: Run `examples/applying-roles.pl` and confirm it terminates**

Run: `perl -Ilib examples/applying-roles.pl`
Expected output:

```
name:   box
width:  10
height: 20
depth:  30
compute_width  => 1024
compute_height => 1024
compute_depth  => 1024
```

- [ ] **Step 5: Add both scripts to `MANIFEST`**

In `MANIFEST`, the `examples/` block currently starts with `examples/moosex-role-parameterized.pl`. The block must be:

```
examples/applying-roles.pl
examples/basics.pl
examples/moosex-role-parameterized.pl
examples/parameters.pl
examples/task-1-weekly-challenge-122.pl
```

- [ ] **Step 6: Verify formatting**

Run: `prove -l xt/author/perltidy.t`
Expected: PASS. (If it fails for either new script, run `perltidy --profile=.perltidyrc -b -bext='/' examples/basics.pl examples/applying-roles.pl` and re-run.)

- [ ] **Step 7: Commit**

```bash
git add examples/basics.pl examples/applying-roles.pl MANIFEST
git commit -m "$(cat <<'EOF'
Add example scripts backing cookbook recipes 1 and 3

examples/basics.pl is the runnable program for the "your first
parameterized role" recipe; examples/applying-roles.pl is the program
for the "applying a role several times" recipe.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

---

## Task 5: Bound the infinite loop in `examples/task-1-weekly-challenge-122.pl`

**Files:**
- Modify: `examples/task-1-weekly-challenge-122.pl:51-64`

This script ends in `while (1) { ...; sleep 1 }`, so it never returns and cannot be run by the author test. Bound it to a fixed number of iterations and drop the `sleep`.

- [ ] **Step 1: Replace the `stream_average` sub and its call**

In `examples/task-1-weekly-challenge-122.pl`, replace:

```perl
sub stream_average {
    my ($stream) = @_;
    my $count    = 0;
    my $sum      = 0;
    while (1) {
        ++$count;
        my $n = $stream->next;
        $sum += $n;
        say $count, "\t$n\t$sum / $count\t", $sum / $count;
        sleep 1;
    }
}

stream_average( 'Stream::TenPlusTen'->new() );
```

with:

```perl
sub stream_average {
    my ( $stream, $iterations ) = @_;
    my $count = 0;
    my $sum   = 0;
    while ( $count < $iterations ) {
        ++$count;
        my $n = $stream->next;
        $sum += $n;
        say $count, "\t$n\t$sum / $count\t", $sum / $count;
    }
}

stream_average( 'Stream::TenPlusTen'->new(), 10 );
```

- [ ] **Step 2: Run the script and confirm it now terminates**

Run: `perl -Ilib examples/task-1-weekly-challenge-122.pl`
Expected: 10 tab-separated lines (counts 1 through 10), then the program exits promptly with no `sleep` delay. The first line is `1	10	10 / 1	10`.

- [ ] **Step 3: Verify formatting**

Run: `prove -l xt/author/perltidy.t`
Expected: PASS. (If it fails, run `perltidy --profile=.perltidyrc -b -bext='/' examples/task-1-weekly-challenge-122.pl` and re-run.)

- [ ] **Step 4: Commit**

```bash
git add examples/task-1-weekly-challenge-122.pl
git commit -m "$(cat <<'EOF'
Bound the arithmetic-stream example so it terminates

The script ended in an unbounded while(1) loop with a sleep, so it
never returned. stream_average now stops after a fixed number of
iterations and the sleep is gone, letting the author test run it to
completion while it stays a valid demonstration.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

---

## Task 6: Add the `xt/author/examples.t` author test

**Files:**
- Create: `xt/author/examples.t`

- [ ] **Step 1: Create `xt/author/examples.t`**

Create the file with exactly this content:

```perl
use strict;
use warnings;

use Test::More;
use File::Spec;

my @scripts = sort glob 'examples/*.pl';

plan skip_all => 'no example scripts found in examples/' unless @scripts;
plan tests => scalar @scripts;

my $devnull = File::Spec->devnull;

for my $script (@scripts) {
    my $status = system qq{"$^X" -Ilib "$script" > $devnull 2>&1};
    is( $status, 0, "$script runs to a clean exit" );
}
```

The test runs every `examples/*.pl` script in a child process with `lib/` on
`@INC`, suppresses each script's output, and asserts a zero wait status. It is
glob-driven, so example scripts added later are picked up automatically.

- [ ] **Step 2: Run the new author test**

Run: `prove -l xt/author/examples.t`
Expected: PASS — 5 subtests (`applying-roles.pl`, `basics.pl`,
`moosex-role-parameterized.pl`, `parameters.pl`, `task-1-weekly-challenge-122.pl`),
each "runs to a clean exit".

- [ ] **Step 3: Verify it does not hang and the whole `xt/` suite passes**

Run: `prove -lr xt`
Expected: `xt/author/examples.t`, `xt/author/perlcritic.t`, and
`xt/author/perltidy.t` all pass, and the run finishes without hanging.

- [ ] **Step 4: Commit**

```bash
git add xt/author/examples.t
git commit -m "$(cat <<'EOF'
Add xt/author/examples.t to run the example scripts

The author test runs every examples/*.pl script and asserts a clean
exit, so the cookbook recipes cannot drift from working code. It is
excluded from the CPAN tarball by the existing ^xt/ MANIFEST.SKIP rule.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

---

## Task 7: Sync `AGENTS.md` with the Phase 1 additions

**Files:**
- Modify: `AGENTS.md`

The "experimental" wording in `AGENTS.md` was already fixed in Task 1. This task adds the new posture/layout facts: `SECURITY.md`, the cookbook module, and the examples author test.

- [ ] **Step 1: Mention `SECURITY.md` in the Project section**

In `AGENTS.md`, replace:

```
Minimum Perl is 5.12 (CI matrix runs Perl 5.12 and the latest stable). Patches must be submitted against the `devel` branch.
```

with:

```
Minimum Perl is 5.12 (CI matrix runs Perl 5.12 and the latest stable). Patches must be submitted against the `devel` branch.

Security vulnerabilities should be reported privately as described in `SECURITY.md`, not through public issues.
```

- [ ] **Step 2: Add the examples author test to the author-tests block**

In `AGENTS.md`, replace:

```
Lint / format — these run as author tests under `xt/`, enforced by GitHub Actions:

```
prove -l xt/author/perlcritic.t   # Perl::Critic over lib/
prove -l xt/author/perltidy.t     # perltidy formatting check
prove -lr xt                      # both at once
```
```

with:

```
Author tests under `xt/` — perlcritic and perltidy are enforced by GitHub Actions:

```
prove -l xt/author/perlcritic.t   # Perl::Critic over lib/
prove -l xt/author/perltidy.t     # perltidy formatting check
prove -l xt/author/examples.t     # run every examples/*.pl script
prove -lr xt                      # all of them at once
```
```

- [ ] **Step 3: Document the cookbook module in the Architecture section**

In `AGENTS.md`, the Architecture section ends with the `### $VERBOSE flag` block, immediately followed by `## Releasing`. Insert a new subsection between them, so that region reads:

```
### `$VERBOSE` flag
`$MooX::Role::Parameterized::VERBOSE` (default false) controls non-fatal warnings (method override, `apply` deprecation carp, redefining `with`). Tests rely on the silent default — flipping it on may add unexpected output.

### `lib/MooX/Role/Parameterized/Cookbook.pm` — documentation only
POD-only module: five recipes with worked examples, no executable code. Each recipe is backed by a script in `examples/`, and `xt/author/examples.t` runs them all.

## Releasing
```

- [ ] **Step 4: Verify the Markdown still reads correctly**

Run: `grep -n 'SECURITY.md\|examples.t\|Cookbook.pm' AGENTS.md`
Expected: three regions reported — the SECURITY.md sentence, the `examples.t` line in the author-tests block, and the Cookbook subsection heading.

- [ ] **Step 5: Commit**

```bash
git add AGENTS.md
git commit -m "$(cat <<'EOF'
Sync AGENTS.md with the Phase 1 documentation additions

Notes the SECURITY.md reporting policy, the new xt/author/examples.t
author test, and the POD-only Cookbook module.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

---

## Task 8: Record the Phase 1 changes in the `Changelog`

**Files:**
- Modify: `Changelog`

Phase 1 has no release of its own (per the spec); the changes ride along with
the next functional release. Record them under an unreleased stanza so the next
release simply replaces the header with its version and date.

- [ ] **Step 1: Prepend an unreleased stanza**

In `Changelog`, the file currently begins with:

```
0.600   Fri May 16 2026 08:39:52 CEST
```

Insert this stanza above that line, followed by one blank line:

```
next    (unreleased)
  - drop the "experimental" framing from the documentation
  - add SECURITY.md with a private vulnerability-reporting policy
  - add MooX::Role::Parameterized::Cookbook documentation page
  - add examples/basics.pl and examples/applying-roles.pl
  - bound the arithmetic-stream example so it terminates
  - add xt/author/examples.t to run the example scripts
```

So the top of the file reads:

```
next    (unreleased)
  - drop the "experimental" framing from the documentation
  - add SECURITY.md with a private vulnerability-reporting policy
  - add MooX::Role::Parameterized::Cookbook documentation page
  - add examples/basics.pl and examples/applying-roles.pl
  - bound the arithmetic-stream example so it terminates
  - add xt/author/examples.t to run the example scripts

0.600   Fri May 16 2026 08:39:52 CEST
```

- [ ] **Step 2: Run the full test suite once more**

Run: `prove -lr t && prove -lr xt`
Expected: every test passes.

- [ ] **Step 3: Commit**

```bash
git add Changelog
git commit -m "$(cat <<'EOF'
Record the Phase 1 documentation changes in the Changelog

An unreleased stanza; the next release replaces the header with its
version and date.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 4: Push the feature branch and open a pull request**

This pushes a branch and opens a PR — confirm with the maintainer before running.

```bash
git push -u origin feature/phase-1-docs-posture
gh pr create --base devel --title "Phase 1: documentation & posture" --body "$(cat <<'EOF'
Implements the Phase 1 spec (`docs/superpowers/specs/2026-05-16-phase-1-docs-posture-design.md`):

- drops the "experimental" framing from the documentation
- adds `SECURITY.md`
- adds the `MooX::Role::Parameterized::Cookbook` page
- adds `examples/basics.pl` and `examples/applying-roles.pl`
- bounds the arithmetic-stream example so it terminates
- adds `xt/author/examples.t`

No functional code changes; the distribution stays on 0.x numbering.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## Task 9: Branch reconciliation — sync `master` to `v0.600`

**Files:** none (Git only). This task is independent of the `feature/phase-1-docs-posture` branch and edits no files. It updates the remote `master` branch.

This task pushes to the remote — **confirm with the maintainer before running the push.** No feature branches are deleted (per the spec).

- [ ] **Step 1: Confirm `master` can be fast-forwarded to `v0.600`**

Run: `git fetch origin && git merge-base --is-ancestor origin/master v0.600 && echo "fast-forward OK"`
Expected: `fast-forward OK`. If nothing prints, `master` is *not* an ancestor of the `v0.600` tag — stop and consult the maintainer rather than force-updating.

- [ ] **Step 2: Fast-forward local `master` to the `v0.600` tag**

```bash
git checkout master
git merge --ff-only v0.600
```

Expected: `master` now points at the `v0.600` release commit.

- [ ] **Step 3: Push the updated `master`**

```bash
git push origin master
```

- [ ] **Step 4: Return to the working branch**

```bash
git checkout feature/phase-1-docs-posture
```

- [ ] **Step 5: Verify the result**

Run: `git log -1 --oneline origin/master && git describe --tags origin/master`
Expected: `origin/master` resolves to the `v0.600` release commit and `git describe` reports `v0.600`.

---

## Done

When all tasks are complete:

- No "experimental" framing remains in `lib/`, `README.md`, or `AGENTS.md`.
- `SECURITY.md` exists and is listed in `MANIFEST`.
- `MooX::Role::Parameterized::Cookbook` exists, is in `MANIFEST`, appears in the
  META `provides` map, and is linked from the main module's SEE ALSO.
- Five `examples/*.pl` scripts exist and all terminate.
- `prove -lr t` and `prove -lr xt` both pass.
- `master` reflects the `v0.600` release; no branches were deleted.
- The Phase 1 changes are recorded in the `Changelog` under an unreleased stanza.
