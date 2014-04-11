package Mistress::Role::HasPlugins;
# ABSTRACT: Module::Pluggable in fewer keystrokes.

use Moo::Role;
use List::Util 'all';
use Module::Pluggable
  search_path => ['Mistress::Plugin'],
  sub_name    => '_list_plugins';

# VERSION

=head1 SYNOPSIS

    # Here is a plugin (in Mistress::Plugin) that does Role::A:
    package Mistress::Plugin::DoSomeA;
    use Moo;
    with 'Mistress::Role::A';

    # Here is another plugin (still in Mistress::Plugin) that does Role::B:
    package Mistress::Plugin::DoSomeB;
    use Moo;
    with 'Mistress::Role::B';

    # Here is yet another plugin (still etc.) that does Role::A *and* Role::B:
    package Mistress::Plugin::DoBothAB;
    use Moo;
    with 'Mistress::Role::A', 'Mistress::Role::B';

    # Here is a class that uses plugins (all stored in Mistress::Plugin),
    # but *only* those which do *both* Role::A and Role::B:
    package Mistress::Whatever;
    use Moo;
    with 'Mistress::Role::HasPlugins'; # <-- that's me!
    sub plugin_roles { qw/ A B / }

    # later in the same class ...
    my @plugins = $self->plugins; # only 'Mistress::Plugin::DoBothAB'!

=head1 DESCRIPTION

This role is a wrapper around L<Module::Pluggable> to simplify plugin
discrimination based on what role is implemented by each plugin.

It requires a C<plugin_roles> method that returns a list of role names
(without their C<'Mistress::Role::'> prefix); in return, it provides a
C<plugins> method that works just like the Module::Pluggable's one, but with
an additional filtering step: it discards plugins that do not implement
Mistress roles specified through C<plugin_roles>. See the L<SYNOPSIS> for a
detailed example.

=cut

requires 'plugin_roles';

sub plugins {
    my $self = shift;

    # Keep only plugins that do *every* roles listed by plugin_roles()
    grep {
        my $p = $_;
        all { $p->does( 'Mistress::Role::' . $_ ) } $self->plugin_roles
    } $self->_list_plugins;
}

1;
