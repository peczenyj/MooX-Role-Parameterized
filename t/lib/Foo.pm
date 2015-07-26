package Foo;

use Moo;

use Bar;

Bar->apply( { attr => 'baz', method => 'run' } );

with 'Bar';

has foo => ( is => 'ro' );

1;
