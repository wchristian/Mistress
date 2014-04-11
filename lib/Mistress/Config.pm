package Mistress::Config;
# ABSTRACT: Allows all other Mistress components to access the configuration.

use Moo;
use MooX::Types::MooseLike::Base qw( Str HashRef );
use Carp 'croak';
use Clone 'clone';
use Config::Any;
use Log::Any '$log';
use Try::Tiny;
use namespace::clean;

# VERSION

=head1 SYNOPSIS

    Mistress::Config->readfile('config.yml');

    # later, somewhere else:

    my $opt = Mistress::Config->get('some/option/key') // 'default';

=head1 DESCRIPTION

This class allows any other Mistress class to access the configuration data
(without altering them), and that configuration's location to change without
loosing track of it.

=cut

has _config => (
    is      => 'rw',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_config',
);

sub _build_config {
    my $self = shift;

    my $config = try {
        defined $self->location or die 'no location specified';
        my $clist = Config::Any->load_files({
            files   => [ $self->location ],
            use_ext => 1,
        });
        my ($config) = values %{ $clist->[0] };
        $log->info( "Mistress::Config: successfully loaded configuration from ",
            $self->location );
        $config;
    }
    catch {
        $log->alert(
            'Mistress::Config: ' . $_ . '! Cannot build a configuration!' );
        croak 'Unable to build a configuration! (see the log)';
    };

    return $config;
}

=attr location

Stores (as a bare string) the path for the configuration file.
This is a C<read-only> attribute.
If you want to change the configuration file's location, use C<< L<readfile> >>.

This path I<should> be absolute, but that's not Mistress::Config's concern.

=cut

has location => (
    is  => 'rwp',
    isa => Str,
    trigger => '_build_config',
);

=method get( "CategoryA/.../KeyC" )

Give access to the configuration produced by L<Config::Any> from the file
which path is in C<location>.

C<get> expects a string as its only argument. This string specifies which
configuration key you want the value. Enumerate all successive keys separated
with a slash (C</>), like in:

    # Our configuration looks like this (YAML):
    x: 42
    A:
        a: 1
        b: 2

    # To get 42:
    Mistress::Config->get('x');

    # To get 2:
    Mistress::Config->get('A/b');

If you ask for a non-terminal value (like C<A> in our previous example), well,
you will get the hashref below C<A>; but not the original! You will get a
I<cloned> hashref, so that configuration data never change (until you call
C<readfile>, of course). So, if you call C<get> without arguments (or with an
empty string), you'll get a copy of the whole configuration hashref.

If you specify an unknown key somewhere in your specification string, C<get>
returns C<undef> and logs that (at I<notice> level).

=cut

sub get {
    my $self = shift;
    my $spec = shift // return clone($self->_config);
    my @keys = split qr{ / }x, $spec;
    my $c = $self->_config;
    my $parent = '_(root)_';
    while ( my $node = shift @keys ) {
        unless ( exists $c->{$node} ) {
            $log->notice( "Mistress::Config::get: no '$node' "
                  . "under '$parent', returning undef" );
            return undef;
        }
        $c = $c->{$node};
        return $c unless ref $c eq 'HASHREF';
        $parent = $node;
    }
    return clone($c);
}

=method readfile( $filename )

If C<$filename> is readable, updates C<location> with C<$filename> and returns
C<1>. Otherwise, logs an error and returns C<0>.

B<Warning:> If an error occurs while Config::Any processes the given file
(which happens lazily, so likely during a later C<get>), the related call will
C<croak>!

=cut

sub readfile {
    my ($self, $filename) = @_;
    unless (-r $filename) {
        $log->error("Mistress::Config::readfile: can't read $filename!");
        return 0;
    }
    $self->location($filename); # triggers _build_config()
    return 1;
}

1;
