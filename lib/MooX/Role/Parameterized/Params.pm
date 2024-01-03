package MooX::Role::Parameterized::Params;

use strict;
use warnings;

# ABSTRACT: allow create role parameter objects.

use Moo::Role;
use MooX::Role::Parameterized;

our $VERSION = "0.5O0";

role {
    my ( $params, $mop ) = @_;

    my $parameters_definition = $params->{parameters_definition} || [];

    foreach my $parameter_definition ( @{$parameters_definition} ) {
        $mop->has( @{$parameter_definition} );
    }
};

1;

__END__

=head1 NAME

MooX::Role::Parameterized:Params - allow create role parameter objects.

=head1 AUTHOR

Tiago Peczenyj <tiago (dot) peczenyj (at) gmail (dot) com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
