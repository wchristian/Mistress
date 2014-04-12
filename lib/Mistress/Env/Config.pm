package Mistress::Env::Config;
# ABSTRACT: Allows other Mistress components to access the configuration.

use Moo::Role;
with 'Mistress::Env';

use MooX::Types::MooseLike::Base qw( InstanceOf HashRef );
use Carp 'croak';
use YAML::XS 0.35 'LoadFile';
use Try::Tiny;
use Log::Any '$log';
use Mistress::Util 'pcf_r';

use namespace::clean;

# VERSION

=head1 SYNOPSIS

    Mistress->config->load('config.yml');

    # later, somewhere else:

    my $opt = Mistress->config->get( $specification_string );

=head1 DESCRIPTION

This role defines how to access configuration values in L<Mistress>. It is
consumed by L<Mistress::Env::Config::Base> (MECB) which implements a fully
usable I<config> environment, but you may want to replace MECB with something
else, for instance:

=for :list
* if you want to use another specification string with C<get> (say C<"a:b:c">,
  whereas MECB uses C<"a/b/c">); B<warning:> if you really want to do that,
  make your C<get> understand B<both> syntaxes, as Mistress core classes use
  the MECB specification!
* if you want C<get> to C<croak> on specifications that lead to unknown keys;
* if you want an alias on C<get>;
* if you want to be able to change configuration values I<in your code>, you
  can make C<get> stop using L<Clone> to return copies of the underlying
  hashref.

=cut

sub env_name { 'config' }

requires 'get';

has _config => (
    is      => 'rw',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_config',
);

sub _build_config {
    my $self = shift;

    my $config = try {
        defined $self->location or die "no location specified";
        my $config = LoadFile( $self->location->stringify );
        $log->info( "Mistress::Config: successfully loaded configuration from "
              . $self->location->stringify );
        $config;
    }
    catch {
        $log->alert( 'Mistress::Env::Config: ' . $_ );
        $log->alert('Mistress::Env::Config: Cannot build a configuration!');
        croak 'Unable to build a configuration! (see the log)';
    };

    return $config;
}

=attr location

Stores (as a L<Path::Class::File>) the path for the configuration file.  If
you want to change the configuration file's location, consider using C<<
L<load> >> that perform conversions and additional checks.

This path I<should> be absolute, but that's not Mistress::Config's concern.

=cut

has location => (
    is      => 'rw',
    isa     => InstanceOf['Path::Class::File'],
    trigger => \&_build_config,
);

=method load( $filename )

If C<$filename> is readable, updates C<location> with C<$filename> and returns
C<1>. Otherwise, croaks.

=cut

sub load {
    my ($self, $file) = @_;
    $self->location(pcf_r($file)); # triggers _build_config()
    return 1;
}

1;
