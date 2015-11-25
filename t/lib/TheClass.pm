package TheClass;
use strict;
use warnings;

use Moo;
use TheParameterizedRole;

TheParameterizedRole->apply([ 
  { attribute => 'foo' },
  { attribute => 'bar' }
]);
1;
