package Mistress::Env::Config;
# ABSTRACT: Allows other Mistress components to access the configuration.

use Moo::Role;
with 'Mistress::Env';

use Carp 'confess';
use MooX::Types::MooseLike::Base qw( HashRef AnyOf Str HasMethods ConsumerOf );
use Mistress::Util 'pcf_r';

use namespace::clean;

# VERSION

=head1 SYNOPSIS

    Mistress->config->load('config.yml');    # with a filename
    # or:
    Mistress->config->load(
        GET 'http://config.example.com/'     # with a HTTP::Request::Common
    );
    # etc.

    # later, somewhere else:
    my $opt = Mistress->config->get('my/specification/string');
    # or maybe:
    my $opt = Mistress->config->get('my:specification:string');
    # or (why not?):
    my $opt = Mistress->config->get(<<'4AM_STYLE');
        "please" "gimme" v
        v  "ym"          <> "string" v
        > "specification" ^          @
    4AM_STYLE

=head1 DESCRIPTION

This role defines how to access configuration values in L<Mistress>. It is
consumed by L<Mistress::Env::Config::File> (MECF) which implements a fully
usable I<config> environment. You may want to replace MECF with something
else if you're in one of (for instance) the following cases:

=for :list
* You want to use another specification string with C<get> (say C<"a:b:c">,
  when MECF uses C<"a/b/c">). B<Warning:> if you really want to do that,
  make your C<get> understand B<both> syntaxes, as Mistress core classes use
  the MECF specification!
* You want C<get> to C<die> on specifications that lead to unknown keys.
* You want an alias on C<get>.
* You want to be able to change configuration values I<in your code>, you
  can make C<get> stop using L<Clone> to return copies of the underlying
  hashref.
* Your configuration data come from something else than a file on your
  filesystem.

=cut

# This is the role used to compare arbitrary objects used as configuration
# sources in _sources_differ().
my $CMP_ROLE = 'Mistress::Role::ConfigurationSource';

=method component_name()

Because Mistress::Env::Config consumes L<Mistress::Env>.
Returns C<"config">.

=cut

sub component_name { 'config' }

=method get( $spec )

B<Required.>
Interprets the string C<$spec> (in whatever way the consuming class chooses)
to return the configuration value C<$spec> represents.

=cut

requires 'get';

=method _build_config()

C<Required.>
This method is the underlying hashref's builder and is also triggered by
C<load> on effective C<location> change. It expects no arguments and returns an hashref.

=cut

has _config => (
    is      => 'rw',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_config',
);

requires '_build_config';

=attr location

Stores the configuration file's path, or the configuration service's URL, or
whatever is able to provide configuration data through C<load>. If you want to
change this value, consider using C<load> to perform conversions and
additional checks.

Consuming classes B<should override> this attribute to enforce type checking:
here C<location> accepts any object that either is a string, can call
C<stringify()> or consumes L<Mistress::Role::ConfigurationSource>.
B<Warning:> If you do so, and if the type you specify is not C<Str>, check
that it provides a C<stringify> method (L<Path::Class::File> does) or make it
consumes L<Mistress::Role::ConfigurationSource>!
(This is because C<load> need to know if the configuration source has changed
to trigger _build_conf again.)

=cut

has location => (
    is  => 'rwp',
    isa => AnyOf[ Str, HasMethods['stringify'], ConsumerOf[$CMP_ROLE] ],
);

=method load( ... )

B<Required.>
Consuming classes must implement a C<load> method to safely update
C<location>.
The return value of C<load> will be ignored.
L<Mistress::Env::Config::File>, for instance, declares:

    sub load {
        my ($self, $file) = @_;
        $self->location(pcf_r($file));
    }

This role ensure that the underlying configuration hash is rebuild if if the
location has changed.

=cut

requires 'load';

around load => sub {
    my $method = shift;
    my $self   = shift;

    # Save the current location for comparison with the new one
    my $old = $self->location;

    $method->( $self, @_ );

    # No need to trigger _build_config if the location was undef (since
    # _build_config is _conf's builder) or if the location hasn't changed.
    if ( _sources_differ( $old, $self->location ) ) {
        $self->_config( $self->_build_config );
    }
    return;
};

sub _sources_differ {
    my ( $a, $b ) = @_;

    return 1 if ( defined($a) xor defined($b) ) || ( ref($a) xor ref($b) );

    if ( !ref($a) ) { $a ne $b }
    elsif ( $a->can('stringify') && $b->can('stringify') ) {
        $a->stringify ne $b->stringify;
    }
    elsif ( $a->DOES($CMP_ROLE) && $b->DOES($CMP_ROLE) ) {
        not $a->same_as($b);
    }
    else { confess "Can't reliably say if $a and $b are the same source!" }
}

1;
