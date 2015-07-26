package Foo;

use Moo;

use Bar;

Bar->apply( { attr => 'baz', method => 'run' } );

has foo => ( is => 'ro' );

1;
