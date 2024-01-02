use strict;
use warnings;

package Foo;

use Moo::Role;
use MooX::Role::Parameterized;

parameter attr => ( is => "ro", required => 1 );

role {
    my ( $params, $mop ) = @_;

    my $attr = $params->attr;

    $mop->has( $attr => ( is => "rw" ) );
};

1;

package Bar;

use Moo;
use MooX::Role::Parameterized::With;

with Foo => { attr => "foo" };

1;

package main;
use feature 'say';

my $bar = Bar->new( foo => 1 );

say( '$bar->foo is: ', $bar->foo );
