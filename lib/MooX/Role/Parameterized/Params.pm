package MooX::Role::Parameterized::Params;

use strict;
use warnings;
use Moo;

our $VERSION = "0.3O0";

# ABSTRACT: allow create role parameter objects.

sub add_parameter {
    my $klass = shift;

    goto $klass->can("has");
}

use Exporter qw(import);

our @EXPORT = qw(create_parameters_klass);

sub create_parameters_klass {
    my ( $package, @args ) = @_;

    my $klass = "${package}::__MOOX_ROLE_PARAMETERIZED_PARAMS__";

    {
        no strict 'refs';

        @{"${klass}::ISA"} = ('MooX::Role::Parameterized::Params');
    }

    return $klass;
}

1;

__END__

=head1 NAME

MooX::Role::Parameterized:Params - allow create role parameter objects.

=head1 EXPORTS

This package is a L<Moo::Role> and offers one static method C<add_parameter>.

It also exports one subroutine C<create_parameters_klass> that creates a L<Moo> class C<${package}::__MOOX_ROLE_PARAMETERIZED_PARAMS__>
that idoes this role and allow to add parameters on parametric roles.

=head1 AUTHOR

Tiago Peczenyj <tiago (dot) peczenyj (at) gmail (dot) com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website