use Test::Modern -default;
use YAML::XS 'LoadFile';
use Path::Class;

my $classname = 'TestFor::MEC';
eval <<"END_FAKE_PKG" or die "Failed to compile test package: $@";
{
    package $classname;
    use Moo;
    with 'Mistress::Env::Config';
    use YAML::XS 'LoadFile';
    use namespace::clean;

    # Simply return the whole config hashref, whatever arg it gets
    sub get { \$_[0]->_config }

    # Just load the argument in "location"
    sub load { \$_[0]->_set_location( \$_[1] ) }

    # Use YAML::XS::LoadFile to set _conf
    sub _build_config {
        defined \$_[0]->location ? LoadFile( \$_[0]->location ) : {};
    }

    1;
}
END_FAKE_PKG

my $conf = object_ok(
    $classname->new,
    '$conf',
    isa   => $classname,
    does  => [qw/ Mistress::Env Mistress::Env::Config /],
    can   => [qw/ new get component_name load location /],
    clean => 1,
);

my $TEST_CONFIG_FILE = file(qw/ t files example_config.yml /);
my $TEST_CONFIG_YAML = LoadFile("$TEST_CONFIG_FILE")
  or die "Failed to load $TEST_CONFIG_FILE: $!";

# load() has not yet been called, so, _build_config() should return {} and
# therefore get() too.
cmp_deeply( $conf->get, {}, 'correct behavior without having called load()' );

# Should die because {} is not a string, can't stringify() nor consumes
# Mistress::Role::ConfigurationSource:
ok( exception { $conf->load( {} ) }, 'minimal type-checking through load()' );

# $TEST_CONFIG_FILE->can('stringify'), so this should work:
is( exception { $conf->load($TEST_CONFIG_FILE) },
    undef, "loading a Path::Class::File doesn't die" );

cmp_deeply( $conf->location, $TEST_CONFIG_FILE,
    "location's content is as expected" );

# $TEST_CONFIG_YAML should therefore be identical to $config->_conf.

cmp_deeply( $conf->get, $TEST_CONFIG_YAML,
    'the underlying configuration hashref is as expected' );

done_testing();
