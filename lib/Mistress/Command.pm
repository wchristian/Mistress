package Mistress::Command;
# ABSTRACT: Base class providing global options.

use strict;
use warnings;

use App::Cmd::Setup -command;
use Mistress::Config;

# VERSION

=head1 DESCRIPTION

This class provides a C<--config> option to all commands, so that
configuration files can be changed at any moment. Configuration files can be
anything L<Config::Any> knows to read. See L<Mistress::Config> for more
information about configuration.

=cut

sub opt_spec {
    my ( $class, $app ) = @_;
    return (
        [ config => 'path to a configuration file' ],
        $class->options($app),
    );
}

sub validate_args {
    my ( $self, $opts, $args ) = @_;
    Mistress::Config->readfile($opts->{config}) if $opts->{config};
    $self->validate( $opts, $args );
}

1;
