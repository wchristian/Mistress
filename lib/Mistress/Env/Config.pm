package Mistress::Env::Config;
# ABSTRACT: Allows other Mistress components to access the configuration.

use Moo::Role;
with 'Mistress::Env';

use Carp 'confess';
use MooX::Types::MooseLike::Base qw( HashRef Defined );
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
    my $opt = Mistress->config->get('my specification string');
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
else, for instance if you're in one of the following cases:

=for :list
* You want to use another specification string with C<get> (say C<"a:b:c">,
  when MECF uses C<"a/b/c">). B<Warning:> if you really want to do that,
  make your C<get> understand B<both> syntaxes, as Mistress core classes use
  the MECF specification!
* You want C<get> to C<die> on specifications that lead to unknown keys.
* You want an alias on C<get>.
* You want to be able to change configuration values I<in your code>: you
  can make C<get> stop using L<Clone> to return copies of the underlying
  hashref (but be aware of L<Mistress::Env::Config::Hash>).
* Your configuration data come from something else than a file on your
  filesystem.

=cut

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
C<load> on effective C<location> change.
It expects no arguments and returns an hashref.

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
here C<location> accepts any defined value.

=cut

has location => (
    is  => 'rwp',
    isa => Defined,
);

=method load( ... )

B<Required.>
Consuming classes must implement a C<load> method to safely update
C<location>.

This role ensure that the underlying configuration hash is rebuild and the
Mistress component interface refreshed.

The return value of your C<load> implementation will be ignored, because this
role defines a wrapper around it that returns C<1> if the Mistress
configuration was actually updated, and C<0> otherwise (for instance if no
C<components> section was found in the configuration source). Thus,
L<Mistress::Env::Config::File>, for instance, simply declares:

    sub load {
        my ( $self, $file ) = @_;
        $self->location( Mistress::Util::pcf_r($file) );
    }

=cut

requires 'load';

around load => sub {
    my $method = shift;
    my $self   = shift;

    # Save the current location for comparison with the new one
    my $old = $self->location;

    $method->( $self, @_ );

    $self->_config( $self->_build_config );
    return Mistress->_reload_configuration;
};

1;
