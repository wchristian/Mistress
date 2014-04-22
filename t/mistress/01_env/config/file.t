use Test::Modern -default;
use autodie;
use YAML::XS 'LoadFile';
use Path::Class;

# Test file for Mistress::Env::Config::File (MECF)

my $classname = 'Mistress::Env::Config::File';

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

  SKIP: {
        skip '(useless when run by root)', 1 if $> == 0;
        my $shadow;
        for my $f (qw[ /etc/shadow /etc/master.passwd ]) {
            $shadow = $f and last if -e $f && !-r $f;
        }
        skip '(uses a Linux/*BSD-specific file, not found)', 1
          unless $shadow;
        like(
            exception { $conf->load($shadow) },
            qr/not readable/,
            'loading an unreadable file dies'
        );
    }

    is( exception { $conf->load($TEST_CONFIG_FILE) },
        undef, 'can load a readable file' );
};

subtest get => sub {
    my $TEST_CONFIG_YAML = LoadFile("$TEST_CONFIG_FILE")
      or die "Can't load YAML file $TEST_CONFIG_FILE";

    my @key_seq = qw/ Plugins UploadGatherer sources /;

    {
        my $a = $conf->get( join '/' => @key_seq );

        my $b = do {
            my $node = $TEST_CONFIG_YAML;
            $node = $node->{$_} for @key_seq;
            $node;
        };

        cmp_deeply( $a, $b, 'get() seems to work' )
          or diag 'Got: ', explain $a, 'Expected: ', explain $b;
    }

};

done_testing();
