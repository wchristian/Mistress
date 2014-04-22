use Test::Modern -default;
use autodie;
use YAML::XS 'LoadFile';
use Path::Class;

my $classname = 'Mistress::Env::Config::Hash';

eval "require $classname" or die "Can't load $classname: $@";

class_api_ok(
    $classname,
    qw{ new get },               # from MECF
    qw{ load location },         # from Mistress::Env::Config role
    qw{ component_name DOES }    # from Mistress::Env role
);

# Methods from composed roles are tested in test files associated with each
# role, so we test only get() here.

my $TEST_CONFIG_FILE = file(qw( t files example_config.yml ));
my $conf             = new_ok($classname);

$conf->load($TEST_CONFIG_FILE);
cmp_deeply $conf->get, {}, 'whatever non-hashref is loaded is taken as {}';

my $hash = {
    A => { a => 1, b => 2 },
    B => { a => 3, b => 4 },
};
$conf->load($hash);

cmp_deeply $conf->get, $hash, 'with a hashref: same structure';
is ref( $conf->get ), ref($hash), 'with a hashref: same reference';

is $conf->get('B/a'), 3, 'get seems to work';

done_testing();
