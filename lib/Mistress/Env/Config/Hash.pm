package Mistress::Env::Config::Hash;
# ABSTRACT: Mistress light, in-memory, writable configuration component.

our $VERSION = '0.001'; # VERSION

use Moo;
with 'Mistress::Env::Config';

use Carp 'confess';
use Data::Dump 'dump';
use MooX::Types::MooseLike::Base qw( Str );
use Log::Any '$log';

use namespace::clean;


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


sub load {
    my ( $self, $conf ) = @_;
    $conf = {} if ref $conf ne 'HASH';
    $self->_set_location( dump($conf) );
}


# If you change something here, think about changing M::Env::Config::File::get
sub get {
    my $self = shift;
    my $spec = shift // return $self->_config;
    my @keys = split qr{ / }x, $spec;
    my $c = $self->_config;
    my $parent = '(root node)';
    while ( my $node = shift @keys ) {
        unless ( exists $c->{$node} ) {
            $log->notice( component_name()
                  . qq{->get: no "$node" under "$parent", returning undef} );
            return undef;
        }
        $c = $c->{$node};
        return $c unless ref($c) eq 'HASH';
        $parent = $node;
    }
    return $c;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mistress::Env::Config::Hash - Mistress light, in-memory, writable configuration component.

=head1 VERSION

version 0.001

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

=head1 METHODS

=head2 load( $conf )

If C<$conf> is a hashref, use it as new configuration. Otherwise, use C<{}> as
new configuration.

=head2 get( "CategoryA/.../KeyC" )

See the same method in L<Mistress::Env::Config::File>. This one is just an
alias on it.

=head1 AUTHOR

Thibaut Le Page <thilp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Thibaut Le Page.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
