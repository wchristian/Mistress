package Mistress::App::Command;
# ABSTRACT: Base class providing global options for Mistress::App.

use strict;
use warnings;

use App::Cmd::Setup 0.309 -command;
use Path::Class;
use Carp 'confess';
use Mistress;

# VERSION

=head1 DESCRIPTION

This class provides a C<--config> option to all commands, so that
configuration files can be changed at any moment. Configuration files can be
anything L<Config::Any> knows to read. See L<Mistress::Config> for more
information about configuration.

=cut

sub options {}

sub opt_spec {
    my ( $class, $app ) = @_;
    return (
        [
            'c=s' => 'path to a configuration file',
            {
                required  => 1,
                callbacks => {
                    'file is readable' => sub { -r $_[0] }
                }
            }
        ],
        $class->options($app),
    );
}

sub validate {}

sub validate_args {
    my ( $self, $opts, $args ) = @_;
    Mistress::_load_config($opts->{c});
    $self->validate( $opts, $args );
}

1;
