use Test::Modern -default;
use YAML;
use Path::Class;

my $classname = 'TestFor::MEC';
eval <<"END_FAKE_PKG";
{
    package $classname;
    use Moo;
    with 'Mistress::Env::Config';
    use namespace::clean;

    # Simply return the whole config hashref, whatever arg it gets
    sub get {
        \$_[0]->_config
    }
}
END_FAKE_PKG

my $conf = object_ok(
    $classname->new,
    '$conf',
    isa   => $classname,
    does  => [qw/ Mistress::Env Mistress::Env::Config /],
    can   => [qw/ new get env_name load location /],
    clean => 1,
);

my $TEST_CONFIG_FILE = file(qw/ t files example_config.yml /);
my $TEST_CONFIG_YAML = YAML::LoadFile("$TEST_CONFIG_FILE")
  or die "Failed to load $TEST_CONFIG_FILE: $!";

subtest load => sub {
    my $nonexistent = do {
        my $base = '/unexistent/path';
        $base .= '_' while -e $base;
        $base;
    };
    like(
        exception { $conf->load($nonexistent) },
        qr/ not \  exist /x,
        'loading a nonexistent file dies'
    );

    is( $conf->load($TEST_CONFIG_FILE), 1, 'can load a readable file' );
};

subtest location => sub {
    # $TEST_CONFIG_FILE has already been loaded in $config.
    isa_ok( $conf->location, 'Path::Class::File' );
    cmp_deeply( $conf->location, $TEST_CONFIG_FILE,
        "location()'s content is the expected Path::Class::File" );
};

subtest _conf => sub {

    # $TEST_CONFIG_FILE has already been loaded in $config.
    # $TEST_CONFIG_YAML should therefore be identical to $config->_conf.
    # _conf is private to $config, but $classname's get() will dump it anyway!

    cmp_deeply( $conf->get, $TEST_CONFIG_YAML,
        'the underlying configuration hashref is as expected' );
};

done_testing();
