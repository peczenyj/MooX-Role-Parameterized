package TheParameterizedRole;
use strict;
use warnings;
use 5.012;
use Carp;
use autodie;
use utf8;

use Moo::Role;
use MooX::Role::Parameterized;

role {
    my $params = shift;
    my $attribute = $params->{attribute};
    has $attribute => (is => 'ro',
                       default => 'this works');
};

1;
