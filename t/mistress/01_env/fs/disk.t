use Test::Modern -default;
use File::Temp;
use Mistress -nicer;

use Mistress::Env::Fs::Disk;
my $class = 'Mistress::Env::Fs::Disk';

my $fs = object_ok(
    $class->new,
    '$fs',
    isa   => [$class],
    does  => [qw/ Mistress::Env::Fs /],
    clean => 1,
);

my $file = File::Temp->new( UNLINK => 0 );
my $filename = $file->filename;

# Set a fake config key for conf_* functions
Mistress->config->get->{a}{b} = $filename;

# TODO

done_testing();
