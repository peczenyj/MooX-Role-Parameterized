package TheParameterizedRole;
use strict;
use warnings;

use MooX::Role::Parameterized;

role {
    my $params = shift;
    my $attribute = $params->{attribute};
    my $method    = $params->{method};

    hasp $attribute => (is => 'ro',
                       default => 'this works');

    method $method => sub { 'dummy' };
};

use Moo::Role;

has xoxo => ( is => 'ro');

1;
