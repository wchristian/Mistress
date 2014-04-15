# NAME

Mistress - A simple but extensible Perl dist tester.

# VERSION

version 0.001

# SYNOPSIS

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

# DESCRIPTION

# METHODS

## forge\_component( $name, $obj ), remove\_component( $name )

These methods install `$obj` under the name `$name` or remove it from
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

# AUTHOR

Thibaut Le Page <thilp@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Thibaut Le Page.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
