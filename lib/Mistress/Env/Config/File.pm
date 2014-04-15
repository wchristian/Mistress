package Mistress::Env::Config::File;
# ABSTRACT: The basic (and default) way to access the configuration.

use Moo;
with 'Mistress::Env::Config';

use Carp 'confess';
use Clone 'clone';
use Log::Any '$log';
use Try::Tiny;
use YAML::XS 0.35 'LoadFile';
use Mistress::Util 'pcf_r';

use namespace::clean;

# VERSION

=head1 SYNOPSIS

    Mistress->config->load('config.yml');

    # later, somewhere else:

    my $opt = Mistress->config->get('some/option/key') // 'default';

=head1 DESCRIPTION

This class (possibly referred as "MECF" in other files) allows any other
Mistress class to access the contents of the configuration file provided via
the C<-c> switch on command-line invocation.

This is the default I<config> component loaded by Mistress. Therefore, all
other Mistress core classes use the MECF specification style
("some/option/key") when querying the configuration. So, if you choose to use
another I<config> component, ensure its C<get> method supports the MECF-style
specification too!

=cut

sub _build_config {
    my $self = shift;

    my $config = try {
        defined $self->location or return {};
        my $config = LoadFile( $self->location->stringify );
        $log->info( "Successfully loaded configuration from "
              . $self->location->stringify );
        $config;
    }
    catch {
        $log->alert("When loading new configuration: $_");
        $log->alert('Cannot build a configuration!');
        confess "Unable to build a configuration! $_";
    };

    return $config;
}

=method load( $path )

Update Mistress' configuration according to the file that corresponds to
C<$path>.

C<$path> may be either a string or a L<Path::Class::File> object. This method
will die if the file doesn't exist or can't be read.

=cut

sub load {
    my ($self, $file) = @_;
    $self->_set_location(pcf_r($file));
}

=method get( "CategoryA/.../KeyC" )

Give access to the configuration produced by L<YAML::XS> from the file
which path has been given to C<load> and is stored in C<location>.

C<get> expects a string as its only argument. This string specifies which
configuration key you want the value. Enumerate all successive keys separated
with a slash (C</>), like in the following example:

    # Our configuration looks like this (YAML):
    x: 42
    A:
        a: 1
        b: 2

    # To get 42:
    Mistress->config->get('x');

    # To get 2:
    Mistress->config->get('A/b');

If you ask for a non-terminal value (like C<A> in our previous example),
you will get the hashref below C<A>, but not the original one, a
I<cloned> hashref, so that configuration data never change (until you call
C<load>, of course). So, if you call C<get> without arguments (or with an
empty string), you'll get a copy of the whole configuration hashref.

If you specify an unknown key somewhere in your specification string, C<get>
returns C<undef> and logs that (at I<notice> level).

=cut

# If you change something here, think about changing M::Env::Config::Hash::get
sub get {
    my $self = shift;
    my $spec = shift // return clone($self->_config);
    my @keys = split qr{ / }x, $spec;
    my $c = $self->_config;
    my $parent = '(root node)';
    while ( my $node = shift @keys ) {
        unless ( exists $c->{$node} ) {
            $log->notice( component_name()
                  . qq{->get: no "$node" under "$parent", returning undef} );
            return undef;
        }
        $c = $c->{$node};
        return $c unless ref($c) eq 'HASH';
        $parent = $node;
    }
    return clone($c);
}

1;
