package MooX::Role::Parameterized::With;

use strict;
use warnings;

our $VERSION = "0.200";

# ABSTRACT: MooX::Role::Parameterized:With - dsl to apply roles with composition parameters

use Module::Runtime qw(use_module is_module_name);
use Moo::Role       qw();
use Role::Tiny      qw();
use Carp            qw(carp croak);

sub import {
    my $target = caller;

    {
        no strict 'refs';
        no warnings 'redefine';

        carp "will redefine 'with' function injected by Moo"
          if $MooX::Role::Parameterized::VERBOSE;

        *{ $target . '::with' } = \&with;
    }
}

sub with {
    my $target = caller;

    while (@_) {
        my $role = shift;

        eval { use_module($role) };

        carp($@) if $MooX::Role::Parameterized::VERBOSE && $@;

        if ( @_ && ref $_[0] eq 'HASH' ) {
            my $params = shift;
            $role->apply_roles_to_target( $params, target => $target );
        }
        elsif ( $role->can("apply_roles_to_target") ) {
            $role->apply_roles_to_target( {}, target => $target );
        }
        elsif ( Moo::Role->is_role($role) ) {
            Moo::Role->apply_roles_to_package( $target, $role );
            _moo_role_maybe_reset_handlemoose($target);
        }
        elsif ( Role::Tiny->is_role($role) ) {
            Role::Tiny->apply_roles_to_package( $target, $role );
        }
        else {
            croak "Can't apply $role to $target: $role is neither a "
              . "MooX::Role::Parameterized/Moo::Role/Role::Tiny role";
        }
    }
}

# duplicate from Moo::Role
sub _moo_role_maybe_reset_handlemoose {
    if ( $INC{'Moo/HandleMoose.pm'} && !$Moo::sification::disabled ) {    ##no critic (Variables::ProhibitPackageVars)
        goto &Moo::HandleMoose::maybe_reinject_fake_metaclass_for;
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
