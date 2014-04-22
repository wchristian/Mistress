
BEGIN {
  unless ($ENV{RELEASE_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for release candidate testing');
  }
}

use strict;
use warnings;

# this test was generated with {{ ref($plugin) . ' ' . ($plugin->VERSION || '<self>') }}

use Test::More 0.94;
use Test::CleanNamespaces 0.04;

subtest all_namespaces_clean => sub {{
    $skips
    ? "{\n    namespaces_clean(
        " . 'grep { my $mod = $_; not grep { $mod =~ $_ } ' . $skips . " }
            Test::CleanNamespaces->find_modules\n    );\n};"
    : '{ all_namespaces_clean() };'
}}

done_testing;
