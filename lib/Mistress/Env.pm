package Mistress::Env;
# ABSTRACT: Role for Env components in Mistress.

our $VERSION = '0.001'; # VERSION

use Moo::Role;


requires 'component_name';

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mistress::Env - Role for Env components in Mistress.

=head1 VERSION

version 0.001

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

=head1 AUTHOR

Thibaut Le Page <thilp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Thibaut Le Page.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
