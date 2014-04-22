use Test::Modern -default;

my $class = 'Mistress';

use Mistress -nicer;

# Test default accessors
can_ok( $class, 'config' );
isa_ok( $class->config, "${class}::Env::Config::Hash" );
ok !$class->can('fs'), 'no "fs" component loaded';

# Test super cow powers
can_ok( $class, qw/ forge_component remove_component / );

like(
    exception { $class->foobar },
    qr/unknown environment component "foobar"/,
    'dies when asking for an unknown component'
);

my $fake_component = { say => 'hello!' };
$class->forge_component( 'foobar', $fake_component );

cmp_deeply $class->foobar, $fake_component, 'forged components are installed';

$class->remove_component('foobar');

like(
    exception { $class->foobar },
    qr/unknown environment component "foobar"/,
    'component are removed'
);

done_testing();
