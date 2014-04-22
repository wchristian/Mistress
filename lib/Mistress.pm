package Mistress;
# ABSTRACT: A simple but extensible Perl dist tester.

our $VERSION = '0.001'; # VERSION

use Carp 'confess';
use Log::Any '$log';
use Package::Stash;

use namespace::clean;


my $PKG = Package::Stash->new(__PACKAGE__);

sub import {
    my ( $class, $flag ) = @_;
    if ( defined $flag ) {
        if ( $flag eq '-nicer' ) { # god mode
            _install_component( config => 'Mistress::Env::Config::Hash' );
        }
        else { confess qq{Unknown import flag "$flag"} }
    }
    else {
        $PKG->remove_symbol('&forge_component');
        $PKG->remove_symbol('&remove_component');
        _reload_configuration();
    }
}

my %DEFAULT_COMPONENTS = (
    config => 'Mistress::Env::Config::File',
    fs     => 'Mistress::Env::Fs::Disk',
);

# Install a component (of class $module) under the $as accessor name in
# this __PACKAGE__. Dies on any error.
sub _install_component {
    my ( $as, $module ) = @_;

    sub failed { confess qq{When trying to install $module as "$as": }, @_ }

    # Check that we can load $module
    require Class::Load;
    my ( $ok, $errstr ) = Class::Load::try_load_class($module);
    failed($errstr) if !$ok;

    # Check that $module does the Mistress::Env role
    $module->DOES('Mistress::Env')
      or failed("$module DOES not the Mistress::Env role");

    # Check that we are registering $module under the name it expects
    $module->component_name eq $as
      or failed( "$module expects to be loaded as " . $module->component_name );

    # Install an instance of $module in __PACKAGE__, overriding any previous one
    my $component = $module->new;
    $PKG->add_symbol( '&' . $as => sub { $component } );
}

# Use the current "config" component to change component accessors according
# to the configuration. If no configuration can be found for
# 'Mistress/components', simply return 0 after installing defaults components.
# Otherwise return 1.
sub _reload_configuration {
    while ( my ( $as, $module ) = each %DEFAULT_COMPONENTS ) {
        _install_component( $as => $module );
    }

    my $env_config = Mistress->config->get('Mistress/components') or return 0;

    while ( my ( $as, $module ) = each %$env_config ) {
        _install_component( $as => $module );
    }

    return 1;
}


sub forge_component {
    my ($class, $as, $obj) = @_;
    $PKG->add_symbol('&' . $as, sub { $obj });
    return;
}

sub remove_component {
    my ($class, $as) = @_;
    $PKG->remove_symbol('&' . $as);
    return;
}

sub AUTOLOAD {
    our $AUTOLOAD;
    my ($nonexistent) = $AUTOLOAD =~ / (?<=::) (.+) $ /x;
    confess qq{Tried to access unknown environment component "$nonexistent"};
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mistress - A simple but extensible Perl dist tester.

=head1 VERSION

version 0.001

=head1 SYNOPSIS

    ### Standard way: ask Mistress to use her components
    #
    use Mistress;

    Mistress->config->... # defaults to Mistress::Env::Config::File
    Mistress->fs->...

    ### God-mode: tell Mistress what she needs to know
    #
    use Mistress -nicer;

    # Now Mistress->config is an empty Mistress::Env::Config::Hash and no
    # other components are loaded.

    # Install/remove components on the fly
    Mistress->forge_component( 'foo', Test::MockObject->new );
    # can now use Mistress->foo->...
    Mistress->remove_component( 'foo' );
    # 'Access to unknown environment component "foo"'

=head1 DESCRIPTION

=head1 METHODS

=head2 forge_component( $name, $obj ), remove_component( $name )

These methods install C<$obj> under the name C<$name> or remove it from
Mistress. Thus:

    use Test::More;
    use Mistress -nicer;

    ok !Mistress->can('foo');    # ok: no default component 'foo'

    # Let's install a "foo" component:
    Mistress->forge_component( 'foo', {} );
    can_ok( 'Mistress', 'foo' );    # ok: we installed 'foo'
    is_deeply( Mistress->foo, {} ); # ok: our $obj was {}

    # Now let's remove "foo":
    Mistress->remove_component('foo');
    ok !Mistress->can('foo');       # ok: no registered component 'foo' anymore

=head1 AUTHOR

Thibaut Le Page <thilp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Thibaut Le Page.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
