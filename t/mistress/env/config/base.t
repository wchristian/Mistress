use Test::Modern -default;
use Log::Any::Test;
use Log::Any '$log';
use autodie;
use YAML::XS 'LoadFile';
use Path::Class;

# Test file for Mistress::Env::Config::Base (MECB)

my $classname = 'Mistress::Env::Config::Base';

eval "require $classname";

class_api_ok(
    $classname,
    qw{ new get },          # from MECB
    qw{ load location },    # from Mistress::Env::Config role
    qw{ env_name DOES }     # from Mistress::Env role
);

# Methods from composed roles are tested in test files associated with each
# role, so we test only get() here.

my $config_file = file(qw( t files example_config.yml ));
my $bare_config = LoadFile("$config_file")
  or die "Can't load YAML file $config_file";

my @key_seq = qw/ Plugins UploadGatherer sources /;
my $config  = new_ok($classname);
is $config->load($config_file), 1,
  'if this test fails, there is something wrong in Mistress::Env::Config'
  or die "Can't continue testing MECB if Mistress::Env::Config "
  . "does not pass its own tests!\n";

{
    my $a = $config->get( join '/' => @key_seq );

    my $b = do {
        my $node = $bare_config;
        $node = $node->{$_} for @key_seq;
        $node;
    };

    cmp_deeply( $a, $b, 'get() seems to work' )
      or diag 'Got: ', explain $a, 'Expected: ', explain $b;
}

done_testing();
