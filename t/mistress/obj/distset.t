use Test::Modern -default;
use Class::Load 'load_class';

my $class = 'Mistress::Obj::DistSet';
load_class($class);

my $ds = object_ok(
    $class->new,
    isa   => [$class],
    does  => ['Mistress::Role::HasPlugins'],
    api   => [qw/ new dists DOES plugins /],
    clean => 1,
);

done_testing();
