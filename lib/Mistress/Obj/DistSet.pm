package Mistress::Obj::DistSet;
# ABSTRACT: Set of Mistress::Obj::Dist objects.

use Moo;
use MooX::Types::MooseLike::Base qw( HashRef Bool );
use Digest::MD5;
use Path::Class;
use Log::Any '$log';
use Mistress;
use Mistress::Util qw( conf2pcf r );
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

my $FINGERPRINT_FILE = '.fingerprints';

has dists => (
    is      => 'rwp',
    isa     => HashRef['Mistress::Obj::Dist'],
    lazy    => 1,
    builder => '_build_dists',
);

has _fingerprints => (
    is      => 'ro',
    isa     => HashRef,      # used as a set
    lazy    => 1,
    builder => '_build_fingerprints',
);

has _fpflag => (
    is  => 'rw',
    isa => Bool,
);

sub _build_fingerprints {
    my $self   = shift;
    my $struct = do {
        my $path = conf2pcf( 'Mistress/workdir', $FINGERPRINT_FILE );
        r($path) ? Mistress->fs->path_load($path) : do {
            $log->notice("No $path available for reading, creating one");
            { flag => 0, fp => {} };
        };
    };
    $self->_fpflag( $struct->{flag} );
    return $struct->{fp};
}

sub _save_fingerprints {
    my $self = shift;
    Mistress->fs->path_dump(
        conf2pcf('Mistress/workdir', $FINGERPRINT_FILE ),
        { flag => !$self->_fpflag, fp => $self->_fingerprints }
    );
}

sub _build_dists {
    my $self = shift;
    my %dists;
    for my $p ( $self->plugins('DistGatherer') ) {
        for my $dist ( @{ $p->dists } ) {
            if ( exists $self->_fingerprints->{ $dist->md5 } ) {
                $log->infof(
                    "Ignoring %s: already considered but not yet processed");
                next;
            }
            $self->_fingerprints->{ $dist->md5 } = !$self->_fpflag;
            $dists{ $dist->name } = $dist;
        }
    }
    delete $self->_fingerprints->{$_}
      for grep { !( $self->fingerprints->{$_} xor $self->_fpflag ) }
      keys %{ $self->fingerprints };
    $self->_save_fingerprints;
}

1;
