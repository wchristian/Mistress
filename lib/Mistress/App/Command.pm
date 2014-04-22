package Mistress::App::Command;
# ABSTRACT: Base class providing global options for Mistress::App.

use strict;
use warnings;

use App::Cmd::Setup 0.309 -command;
use Path::Class;
use Carp 'confess';
use Mistress;

our $VERSION = '0.001'; # VERSION


sub options {}

sub opt_spec {
    my ( $class, $app ) = @_;
    return (
        [
            'c=s' => 'path to a YAML configuration file',
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
    Mistress->config->load($opts->{c});
    $self->validate( $opts, $args );
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mistress::App::Command - Base class providing global options for Mistress::App.

=head1 VERSION

version 0.001

=head1 DESCRIPTION

This class provides a C<-c> (B<-c>onfig) option to all commands, so that
configuration files can be changed at any moment. Configuration files are
YAML; see L<Mistress::Config> for more information about configuration.

=head1 AUTHOR

Thibaut Le Page <thilp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Thibaut Le Page.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
