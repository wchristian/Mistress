package Mistress::Role::ConfigSource;
# ABSTRACT: Role for objects that represent a configuration source for Mistress

# VERSION

use Moo::Role;
use Safe::Isa;
use Carp 'confess';

use namespace::clean;

=head1 SYNOPSIS

=head1 DESCRIPTION

A "configuration source" is whatever Mistress can use to put data in its own
configuration. This role represents objects used to implement these sources:
for instance, filesystem paths or URLs.

L<Mistress::Env::Config> needs to know if a configuration source has changed
or not after a call to C<load>. Therefore, configuration sources must be
comparable. This is easy when dealing with strings, but can't be reliably done
with arbitrary objects.

This role must be consumed by any object used to represent a configuration
source in Mistress (to put it simply: anything that you give to C<<
Mistress->config->load( ... ) >>). This is not necessary for bare strings nor
objects that implement a C<stringify> method (as L<Path::Class::File> does).

=cut

=method $self->same_as( $other )

B<Required.>
Returns true if C<$self> and C<$other> represent the same configuration source.

Regardless of your C<same_as> implementation, this method will die unless
C<$other>'s class is a subclass of (or the same class as) C<$self>.

=cut

requires 'same_as';

before same_as => sub {
    my ( $self, $other ) = @_;
    $other->$_isa( ref($self) )
      or confess "same_as argument must be of the same type than its invocant";
};

1;
