use strict;
use warnings;

use Test::More;
use Test::Exception;

use MooX::Role::Parameterized;

throws_ok {
    hasp "...";
}
qr/hasp is deprecated and should not be used/, "call hasp should croak";

throws_ok {
    method "...";
}
qr/method is deprecated and should not be used/, "call method should croak";

done_testing;
