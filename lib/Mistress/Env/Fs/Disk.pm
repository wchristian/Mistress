package Mistress::Env::Fs::Disk;
# ABSTRACT: Implements Mistress::Env::Fs for a real, local filesystem.

use Moo;
with 'Mistress::Env::Fs';

use Carp 'confess';
use MooX::Types::MooseLike::Base qw( InstanceOf );
use Path::Class;
use Sereal::Encoder 'sereal_encode_with_object';
use Sereal::Decoder qw/ sereal_decode_with_object scalar_looks_like_sereal /;
use Package::Stash;
use Mistress::Util 'pcf';

use namespace::clean;

our $VERSION = '0.001'; # VERSION


has _encoder => (
    is      => 'rwp',
    isa     => InstanceOf['Sereal::Encoder'],
    lazy    => 1,
    builder => '_build_encoder',
);

has _decoder => (
    is      => 'rwp',
    isa     => InstanceOf['Sereal::Decoder'],
    lazy    => 1,
    builder => '_build_decoder',
);

sub _build_encoder { Sereal::Encoder->new }

sub _build_decoder { Sereal::Decoder->new }

# Only a fool would naively write an implementation for each of the methods
# required in Mistress::Env::Fs! Here, for each method we want create, we have
# two subs: one in %prefixes and the other in %methods. The one in %prefixes
# standardizes its arguments; the one in %methods does what is expected with
# these arguments. These subs are combined and installed in __PACKAGE__.
BEGIN {

    # These methods are expected to perform validation and coercion of their
    # arguments, so that subs in %methods all get ($self, $path, @other)
    # where $path is a Path::Class::File and @other stores remaining
    # arguments.
    my %prefixes = (
        path => sub {
            my $self = shift;
            my $path = shift;
            return ( $self, pcf($path), @_ );
        },
        conf => sub {
            my ( $self, $key, @other ) = @_;
            my $path = Mistress->config->get($key)
              or confess "$key does not exist: can't find a path to work with";
            return ( $self, file($path), @other );
        },
    );

    # These methods will be passed the following arguments: $self and a
    # Path::Class::File to work with, and possibly remaining method-specific
    # arguments in the same order than specified in Mistress::Env::Fs.
    my %methods = (
        openr => sub { $_[1]->openr },
        openw => sub { $_[1]->openw },
        slurp => sub { $_[1]->slurp },
        spew  => sub { $_[1]->spew( $_[2] ) },
        dump  => sub {
            my ( $self, $path, $data ) = @_;
            my $fh = $path->openw;
            print {$fh} sereal_encode_with_object( $self->_encoder, $data );
            return;
        },
        load => sub {
            my ( $self, $path ) = @_;
            my $blob = $path->slurp;
            scalar_looks_like_sereal($blob)
              or confess
              "Can't deserialize from $path: doesn't look like Sereal data";
            sereal_decode_with_object( $self->_decoder, $blob );
        },
    );

    my $pkg = Package::Stash->new(__PACKAGE__);
    for my $p ( keys %prefixes ) {
        for my $m ( keys %methods ) {
            $pkg->add_symbol( '&' . $p . '_' . $m,
                sub { $methods{$m}->( $prefixes{$p}->(@_) ) } );
        }
    }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mistress::Env::Fs::Disk - Implements Mistress::Env::Fs for a real, local filesystem.

=head1 VERSION

version 0.001

=head1 SYNOPSIS

See L<Mistress::Env::Fs>.

=head1 DESCRIPTION

This class consume L<Mistress::Env::Fs> to provide access to the OS's
filesystem, which should be appropriate in most cases. It uses L<Sereal> for
(de)serialization.

=head1 AUTHOR

Thibaut Le Page <thilp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Thibaut Le Page.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
