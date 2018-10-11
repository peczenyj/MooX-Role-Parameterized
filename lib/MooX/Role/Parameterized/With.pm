package MooX::Role::Parameterized::With;
use strict;
use warnings;

# ABSTRACT: MooX::Role::Parameterized:With - dsl to apply roles with composition parameters

use Module::Runtime qw(use_module);
use List::MoreUtils qw(natatime);
use Moo::Role qw();
use Role::Tiny qw();

sub import {
    my $package = shift;
    my $target  = caller;

    my $it = natatime( 2, @_ );

    while ( my ( $role, $params ) = $it->() ) {
        use_module($role);
        if (%$params) {
            $role->apply( $params, target => $target );
        } else {
            if ($role->can("apply")) {
                $role->apply( $params, target => $target );
            } elsif (Moo::Role->is_role($role)) {
                Moo::Role->apply_roles_to_package( $target, $role );
                Moo::Role->_maybe_reset_handlemoose($target);
            } elsif (Role::Tiny->is_role($role)) {
                Role::Tiny->apply_roles_to_package( $target, $role );
            } else {
                die "Can't apply $role to $target: $role is neither a ".
                    "MooX::Role::Parameterized/Moo::Role/Role::Tiny role";
            }
        }
    }
}

1;

__END__

=head1 NAME

MooX::Role::Parameterized:With - dsl to apply roles with composition parameters

=head1 SYNOPSIS

    package FooWith;

    use Moo;
    use MooX::Role::Parameterized::With Bar => {
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
