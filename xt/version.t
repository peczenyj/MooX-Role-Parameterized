use strict;
use warnings;
use Test::More;

eval "use Test::Version 1.001001 qw<version_all_ok>, "
  . "{ has_version => 1, consistent => 1 }";
plan skip_all =>
  "Test::Version 1.001001+ required for version coherence checks"
  if $@;

# has_version: every .pm declares a $VERSION literal.
# consistent:  every $VERSION matches the distribution version.
# Guards against the kind of drift fixed in v0.502 (a "0.5O1" typo,
# letter O for zero, in one module's $VERSION).
version_all_ok();
done_testing();
