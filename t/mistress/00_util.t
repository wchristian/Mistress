use Test::Modern -default;
use Path::Class;
use File::Temp;

my $classname = 'Mistress::Util';
eval "require $classname" or die "Failed to load $classname: $!";

my $LINUX_OR_BSD = qr{ ^ (?: Linux | .*BSD.* | Darwin) $ }xi;

import_ok( $classname,
    export_ok => [qw/ pcf pcf_e pcf_r pcf_w conf2pcf e r w /], );

sub tests_for_pcf_X {
    my $func_name = shift;
    my $func      = \&{"${classname}::${func_name}"};

    # Undef as path dies
    like( exception { $func->() },
        qr/ undef /x, 'having no argument produces an exception' );
    like( exception { $func->(undef) },
        qr/ undef /x, 'explicit undef argument produces an exception' );

    # Various refs as path dies
    like(
        exception { $func->( { test => 1 } ) },
        qr/ reference /x,
        'hashref argument produces an exception'
    );
    like(
        exception { $func->( bless ['hello'] => 'Foo' ) },
        qr/ reference /x,
        'blessed arrayref argument produces an exception'
    );

    # Existing, readable and writable file works
    {
        my $existing_path = file(qw/ t files example_config.yml /);
        -e $existing_path->stat or die "Missing test file!";

        my %results = (
            path => $func->("$existing_path"),
            pcf  => $func->($existing_path),
        );
        while ( my ( $k, $v ) = each %results ) {
            isa_ok $v, 'Path::Class::File';
            is "$v", "$existing_path",
              "produces a valid Path::Class::File from existing $k";
        }

        subtest 'PCF invariance' => sub {
            note(   "These tests ensure that, when given a Path::Class::File, "
                  . "this function returns it unchanged." );
            my $pcf    = $existing_path;
            my $result = $func->($pcf);
            is( ref($result), ref($pcf), 'references are the same' );
            cmp_deeply( $result, $pcf, 'object contents are the same' );
          }
    }

    return $func;
}

sub tests_for_pcf_eX {
    my $func_name = shift;

    my $func = tests_for_pcf_X($func_name);

    # Nonexistent file fails
    {
        my $unexistent_path = do {
            my $base = '/unexistent/path';
            $base .= '_' while -e $base;
            $base;
        };

        my %results = (
            path => exception { $func->($unexistent_path) },
            pcf  => exception { $func->( file($unexistent_path) ) },
        );
        while ( my ( $k, $v ) = each %results ) {
            like $v, qr/ not \  exist /x,
              "throws an exception for nonexistent $k";
        }
    }

    return $func;
}

subtest pcf => sub {

    my $func = tests_for_pcf_X('pcf');

    # Nonexistent file works
    {
        my $unexistent_path = do {
            my $base = '/unexistent/path';
            $base .= '_' while -e $base;
            $base;
        };

        my %results = (
            path => $func->($unexistent_path),
            pcf  => $func->( file($unexistent_path) ),
        );
        while ( my ( $k, $v ) = each %results ) {
            isa_ok $v, 'Path::Class::File';
            is "$v", file($unexistent_path)->stringify,
              "produces a valid Path::Class::File from unexistent $k";
        }

        subtest 'PCF invariance' => sub {
            note(   "These tests ensure that, when given a Path::Class::File, "
                  . "this function returns it unchanged." );
            my $pcf    = file($unexistent_path);
            my $result = $func->($pcf);
            is( ref($result), ref($pcf), 'references are the same' );
            cmp_deeply( $result, $pcf, 'object contents are the same' );
        };
    }
};

subtest pcf_e => sub {

    tests_for_pcf_eX('pcf_e');

};

subtest pcf_r => sub {

    # Must pass all pcf() tests
    my $func = tests_for_pcf_eX('pcf_r');

    subtest readability => sub {

        # Existing and readable file
        # Already tested in tests_for_pcf()

        # Existing but unreadable file
      SKIP: {
            skip '(useless when run by root)', 2 if $> == 0;

            my $shadow;
            for my $f (qw[ /etc/shadow /etc/master.passwd ]) {
                $shadow = $f and last if -e $f && !-r $f;
            }
            skip '(uses a Linux/*BSD-specific file, not found)', 2
              unless $shadow;

            # WARNING: if you add/remove keys/tests, don't forget to update
            # the number of tests in skip()
            my %results = (
                path => exception { $func->($shadow) },
                pcf  => exception { $func->( file($shadow) ) },
            );
            while ( my ( $k, $v ) = each %results ) {
                like $v, qr/ not \  readable /x,
                  "throws an exception from existing but unreadable $k";
            }
        }

    };
};

subtest pcf_w => sub {

    # Must pass all pcf() tests
    my $func = tests_for_pcf_eX('pcf_w');

    subtest writability => sub {

        # Existing and writable file
        # Already tested in tests_for_pcf()

        # Existing but read-only file
      SKIP: {
            skip '(useless when run by root)', 2 if $> == 0;

            my $ro;
            for my $f (qw[ /etc/passwd ]) {
                $ro = $f and last if -r $f && !-w $f;
            }
            skip '(uses a Linux/*BSD-specific file, not found)', 2 unless $ro;

            # WARNING: if you add/remove keys/tests, don't forget to update
            # the number of tests in skip()
            my %results = (
                path => exception { $func->($ro) },
                pcf  => exception { $func->( file($ro) ) },
            );
            while ( my ( $k, $v ) = each %results ) {
                like $v, qr/ not \  writable /x,
                  "throws an exception from existing but read-only $k";
            }
        }

        # Existing but unreadable file
      SKIP: {
            skip '(useless when run by root)', 2 if $> == 0;

            my $shadow;
            for my $f (qw[ /etc/shadow /etc/master.passwd ]) {
                $shadow = $f and last if -e $f && !-r $f;
            }
            skip '(uses a Linux/*BSD-specific file, not found)', 2
              unless $shadow;

            # WARNING: if you add/remove keys/tests, don't forget to update
            # the number of tests in skip()
            my %results = (
                path => exception { $func->($shadow) },
                pcf  => exception { $func->( file($shadow) ) },
            );
            while ( my ( $k, $v ) = each %results ) {
                like $v, qr/ not \  writable /x,
                  "throws an exception from existing but unreadable $k";
            }
        }

    };
};

subtest conf2pcf => sub {
    require Mistress;
    Mistress->import('-nicer');
    my $func = \&{"${classname}::conf2pcf"};
    Mistress->config->get->{bar} = 'baz';
    my $f = $func->( 'bar', qw/ quux thud / );
    isa_ok( $f, 'Path::Class::File' );
    is "$f", file(qw/baz quux thud/)->stringify, 'same path';
    like(
        exception { $func->( 'nonexistent', qw/ quux thud / ) },
        qr/no configuration value/i,
        'conf2pcf dies on nonexistent keys'
    );
};

subtest erw => sub {
    use warnings FATAL => 'all';
    my $fh          = File::Temp->new;
    my $file        = $fh->filename;
    my $nonexistent = do {
        my $base = '/nonexistent/path';
        $base .= '_' while -e $base;
        $base;
    };
    for my $f (qw/ e r w /) {
        my $func = \&{"${classname}::$f"};

        # undef
        is exception { $func->(undef) }, undef, "$f handles undef nicely";

        my $test_both = sub {
            my ( $file, $descr ) = @_;
            $descr = "$f behaves like -$f with $descr ";
            is $func->($file), eval "-$f '$file'", $descr . 'files';
            is $func->( file($file) ),
              eval "defined file('$file')->stat && -$f file('$file')->stat",
              $descr . 'Path::Class::File';
        };

        # Nonexistent file
        $test_both->($nonexistent, 'nonexistent');

        # Existing but unreadable file
      SKIP: {
            skip '(useless when run by root)', 1 if $> == 0;

            my $shadow;
            for my $f (qw[ /etc/shadow /etc/master.passwd ]) {
                $shadow = $f and last if -e $f && !-r $f;
            }
            skip '(uses a Linux/*BSD-specific file, not found)', 2
              unless $shadow;

            $test_both->($shadow, 'existing but unreadable');
        }

        # Existing but read-only file
      SKIP: {
            skip '(useless when run by root)', 2 if $> == 0;

            my $ro;
            for my $f (qw[ /etc/passwd ]) {
                $ro = $f and last if -r $f && !-w $f;
            }
            skip '(uses a Linux/*BSD-specific file, not found)', 2 unless $ro;

            $test_both->($ro, 'read-only');
        }

        # Read-writable file
        $test_both->($file, 'read-writable');
    }
};

done_testing();
