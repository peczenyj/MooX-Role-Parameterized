package Bar;

use Moo::Role;
use MooX::Role::Parameterized;

role {
    my ($params) = @_;

    has $params->{attr} => ( is => 'rw' );

    method $params->{method} => sub {
        1024;
    };
};

has bar => ( is => 'ro' );

1;
