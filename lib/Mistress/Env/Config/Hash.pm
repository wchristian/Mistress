package Mistress::Env::Config::Hash;
# ABSTRACT: Mistress light, in-memory, writable configuration component.

# VERSION

use Moo;
with 'Mistress::Env::Config';

use Carp 'confess';
use Data::Dump 'dump';
use Class::Load 'load_class';
use Package::Stash;
use MooX::Types::MooseLike::Base qw( Str );

use namespace::clean;

=head1 SYNOPSIS

    Mistress->config->load( $hashref );

    my $opt = Mistress->config->get('some/option/key') // 'default';

=head1 DESCRIPTION

This class is a I<config> component for L<Mistress> that does not use anything
beyond a hashref: no configuration file, no read-only protection, nothing.

It is most useful for debugging and testing, and as such is the default
I<config> component under C<use Mistress -nicer;>.

It behaves the same than L<Mistress::Env::Config::File>, except that C<load>
expects a hashref (instead of a string or a L<Path::Class::File>), and will
treat anything else as an empty hashref.

=cut

# location is used to temporarily store the serialized hashref
has '+location' => (
    is  => 'rwp',
    isa => Str,
);

sub _build_config {
    my $self = shift;
    defined $self->location or return {};
    eval $self->location or confess "Can't deparse location: $@";
}

=method load( $conf )

If C<$conf> is a hashref, use it as new configuration. Otherwise, use C<{}> as
new configuration.

=cut

sub load {
    my ( $self, $conf ) = @_;
    $conf = {} if ref $conf ne 'HASH';
    $self->_set_location( dump($conf) );
}

=method get( "CategoryA/.../KeyC" )

See the same method in L<Mistress::Env::Config::File>. This one is just an
alias on it.

=cut

BEGIN {
    my $from = 'Mistress::Env::Config::File';
    load_class($from);
    Package::Stash->new(__PACKAGE__)->add_symbol(
        '&get',
        Package::Stash->new($from)->get_symbol('&get')
    );
}

1;
