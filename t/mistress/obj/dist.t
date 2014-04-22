use Test::Modern -default;
use Class::Load 'load_class';
use Path::Class;
use Digest::MD5 'md5_hex';
use File::Temp;
use autodie;

my $class = 'Mistress::Obj::Dist';
load_class($class);

### Fake dist names

like(
    exception { $class->new('TestFor-Fake-Dist-1.tar.gz') },
    qr/does not exist/,
    'new() dies on nonexistent tarball'
);

SKIP: {
    my $nondist;
    {
        for ( 1 .. 20 ) {
            my $tmp = File::Temp->new( SUFFIX => '.tar.gz' );
            $nondist = $tmp and last
              unless $tmp->filename =~ / ^ [a-z0-9.-]+ $ /xi;
        }
        skip "can't get a good temporary file", 2 unless $nondist;
    }
    like(
        exception { $class->new( $nondist->filename ) },
        qr/not a valid dist tarball filename/,
        'new dies on non-distribution filename'
    );
}

### Real dist name

my $tb_fh;
{
    for ( 1 .. 20 ) {
        my $tmp = File::Temp->new(
            TEMPLATE => 'TestForXXXXXX',
            SUFFIX   => '-1.tar.gz'
        );
        $tb_fh = $tmp and last if $tmp->filename =~ / ^ [a-z0-9.-]+ $ /xi;
    }
    plan skip_all => "can't get a good temporary file" unless $tb_fh;
}

my $tb_name = $tb_fh->filename;

my $d = object_ok(
    $class->new($tb_name),
    'real distribution',
    isa   => [$class],
    api   => [qw/ BUILDARGS new name tarball md5 /],
    clean => 1,
);

is $d->name, do {
    ( my $a = $tb_name ) =~ s{ -1\.tar\.gz $ }[]x;
    $a =~ s{-}[::]g;
    $a;
}, '->name ok';

cmp_deeply( $d->tarball, file($tb_name), '->tarball ok' );

is $d->md5, md5_hex(
    do { local $/; <$tb_fh> }
  ), '->md5 ok';

done_testing();
