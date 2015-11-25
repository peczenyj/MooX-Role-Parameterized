package TheClass;
use strict;
use warnings;
use 5.012;
use Carp;
use autodie;
use utf8;

use Moo;
use TheParameterizedRole;

TheParameterizedRole->apply([ 
  { attribute => 'foo' },
  { attribute => 'bar' }
]);
1;
