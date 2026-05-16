use strict;
use warnings;

use Test::More;

eval 'use Test::PerlTidy';
plan skip_all => 'Test::PerlTidy required to check formatting' if $@;

Test::PerlTidy::run_tests(
    perltidyrc => '.perltidyrc',
    exclude    => [ 'blib/', 'Makefile\.PL$' ],
);
