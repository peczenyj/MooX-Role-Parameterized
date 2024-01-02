package MooX::Role::Parameterized::Params;

use strict;
use warnings;
use Exporter qw(import);

our @EXPORT = qw(create_parameters_klass);

use Moo::Role; # convert this to a parameterized role?

sub add_parameter {
    my $klass = shift;

    $klass->can("has")->(@_);
}

sub create_parameters_klass {
    my ( $package, @args ) = @_;

    my $klass = "${package}::__MOOX_ROLE_PARAMETERIZED_PARAMS__";

    eval ##no critic(BuiltinFunctions::ProhibitStringyEval)
      qq( package $klass; use Moo; with 'MooX::Role::Parameterized::Params'; 1; );

    return $klass;
}

1;
