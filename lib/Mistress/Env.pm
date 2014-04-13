package Mistress::Env;
# ABSTRACT: Role for Env components in Mistress.

# VERSION

use Moo::Role;

=head1 SYNOPSIS

    package Mistress::Env::Foo;
    use Moo;
    with 'Mistress::Env';
    sub env_name { 'foo' }
    sub bar { ... }

    # Later, in whatever Mistress class, access Foo methods easily:
    Mistress->foo->bar( ... );

=head1 DESCRIPTION

"Env components" are objects under C<Mistress::Env::*> that consume this
Mistress::Env role. They are special objects in Mistress as they are static
members of the L<Mistress> class (if activated in the configuration file), and
thus are accessible everywhere else with a special syntax.
L<Mistress::Env::Config> is a special case: Mistress will always load it first
(in order to be able to read its configuration file), but if you change it (in
said file), the new "config" env will be used to I<reload> the file.

This role contributes to build these static members by requiring the
C<component_name> method, which must return the name under which the object
will be registered as a Mistress' static member.

B<Warning:> Any object located under C<Mistress::Env::*> but that does not
consume Mistress::Env will be ignored!

=cut

requires 'component_name';

1;
