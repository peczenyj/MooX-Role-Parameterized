use strict;
use warnings;
use Test::More;

use lib 't/lib';
{

    package FooWith;

    use Moo;
    use MooX::Role::Parameterized::With;

    with Bar => { attr => 'baz', method => 'run' };

    has foo => ( is => 'ro' );

}

{

    package FooWithRoleTiny;

    use Moo;
    use MooX::Role::Parameterized::With;

    with BarRoleTiny => { attr => 'baz', method => 'run' };

    has foo => ( is => 'ro' );

}

subtest "FooWith" => sub {

    my $foo = FooWith->new( foo => 1, bar => 2, baz => 3 );

    isa_ok $foo, 'FooWith', 'foo';
    ok $foo->DOES('Bar'), 'foo should does Bar';
    is $foo->foo, 1, 'should has foo';
    is $foo->bar, 2, 'should has bar ( from Role )';
    is $foo->baz, 3, 'should has baz ( from parameterized Role)';
    ok $foo->can('run'), 'should can run';
    is $foo->run, 1024, 'should call run';

    done_testing;

};

subtest "FooWithRoleTiny" => sub {

    my $foo = FooWithRoleTiny->new( foo => 1, baz => 3 );

    isa_ok $foo, 'FooWithRoleTiny', 'foo';
    ok $foo->DOES('BarRoleTiny'), 'foo should does BarRoleTiny';
    is $foo->foo, 1,                      'should has foo';
    is $foo->bar, 'not what you expects', 'should has bar ( from Role )';
    is $foo->baz, 3, 'should has baz ( from parameterized Role)';
    ok $foo->can('run'), 'should can run';
    is $foo->run, 1024, 'should call run';

    done_testing;

};

done_testing;
