package Mistress::Obj::DistSet;
# ABSTRACT: Set of Mistress::Obj::Dist objects.

use Moo;
use MooX::Types::MooseLike::Base qw( HashRef );
use Digest::MD5;
use Path::Class;
use Mistress::Config;
use Mistress::Obj::Dist;

with 'Mistress::Role::HasPlugins';

use namespace::clean;

# VERSION

=head1 SYNOPSIS

=head1 DESCRIPTION

This object builds (and then represents) a set of L<Mistress::Obj::Dist>
objects.

The set is indirectly build through plugins that implement the
L<Mistress::Role::DistGatherer> role. Each of these plugins produces a list of
Dist objects and all these lists are merged here.

Thanks to a blacklist system, only "fresh" distributions (i.e. that have not
been in a DistSet without being "smoked" later) are added to this set.

=cut

sub plugin_roles { 'DistGatherer' }

has dists => (
    is      => 'rwp',
    isa     => HashRef['Mistress::Obj::Dist'],
    lazy    => 1,
    builder => '_build_dists',
);

has _fingerprints => (
    is      => 'rwp',
    isa     => HashRef,      # used as a set
    lazy    => 1,
    builder => '_build_fingerprints',
);

sub _build_fingerprints {
    my $self    = shift;
    my $workdir = Mistress::Config->get('Mistress/workdir');
    my $fp      = file( $workdir, '.fingerprints' );
    return -r $fp->stat ? { map { $_ => 0 } <$fp-> openr > } : {};
}

sub _build_dists {
    my $self = shift;
    ...
}

1;
