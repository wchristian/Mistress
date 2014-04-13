use Test::Modern -default;

my $class = 'Mistress';

use Mistress -nicer;

# Test default accessors
can_ok( $class, 'config' );
isa_ok( $class->config, "${class}::Env::Config::Hash" );
ok !$class->can('fs'), 'no "fs" component loaded';

# Test super cow powers
can_ok( $class, qw/ forge_component remove_component / );

done_testing();
