package MooX::Role::Parameterized::With;

use strict;
use warnings;

our $VERSION = "0.500";

# ABSTRACT: MooX::Role::Parameterized:With - dsl to apply roles with composition parameters

use Carp                      qw(carp);
use MooX::Role::Parameterized qw();

sub import {
    my $target = caller;

    {
        my $orig = $target->can('with');
        carp "will redefine 'with' function"
          if $orig && $MooX::Role::Parameterized::VERBOSE;

        no strict 'refs';
        no warnings 'redefine';

        *{ $target . '::with' } =
          MooX::Role::Parameterized->build_apply_roles_to_package($orig);
    }
}

1;

__END__

=head1 NAME

MooX::Role::Parameterized:With - dsl to apply roles with composition parameters

=head1 SYNOPSIS

    package FooWith;

    use Moo;
    use MooX::Role::Parameterized::With;
    
    with Bar => {
        attr => 'baz',
        method => 'run'
    }, Other::Role => { ... };

    has foo => ( is => 'ro');

=head1 DESCRIPTION

This B<experimental> package try to offer an easy way to add parametrized roles.

Will load and apply L<MooX::Roles::Parameterized> roles, just need use this package
with a hash of role => parameters.

=head1 AUTHOR

Tiago Peczenyj <tiago (dot) peczenyj (at) gmail (dot) com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
