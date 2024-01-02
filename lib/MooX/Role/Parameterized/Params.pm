package MooX::Role::Parameterized::Params;

use strict;
use warnings;
use Moo;

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
