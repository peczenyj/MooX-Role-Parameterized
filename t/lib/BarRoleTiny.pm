package BarRoleTiny;

use Role::Tiny;
use MooX::Role::Parameterized;

role {
    my ( $params, $mop ) = @_;

    $mop->has( $params->{attr} => ( is => 'rw' ) );

    $mop->method(
        $params->{method} => sub {
            1024;
        }
    );
};

sub bar {'not what you expects'}

1;
