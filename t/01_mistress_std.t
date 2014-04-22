use Test::Modern -default;

my $class = 'Mistress';

use Mistress;

# Test default accessors
my %defaults = (
    config => "${class}::Env::Config::File",
    fs     => "${class}::Env::Fs::Disk",
);
can_ok( $class, keys %defaults );
isa_ok( $class->$_, $defaults{$_} ) for keys %defaults;

# Check that {forge,remove}_component() are disabled
ok !$class->can($_), "no $_() method"
  for qw/ forge_component remove_component /;

done_testing();
