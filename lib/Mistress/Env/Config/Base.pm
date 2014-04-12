package Mistress::Env::Config::Base;
# ABSTRACT: The basic (and default) way to access the configuration.

use Moo;
with 'Mistress::Env::Config';

use Clone 'clone';
use Log::Any '$log';

use namespace::clean;

# VERSION

=head1 SYNOPSIS

    Mistress->config->load('config.yml');

    # later, somewhere else:

    my $opt = Mistress->config->get('some/option/key') // 'default';

=head1 DESCRIPTION

This class allows any other Mistress class to access the configuration data
(without altering them), and that configuration's location to change without
loosing track of it.

=cut

=method get( "CategoryA/.../KeyC" )

Give access to the configuration produced by L<Config::Any> from the file
which path is in C<location>.

C<get> expects a string as its only argument. This string specifies which
configuration key you want the value. Enumerate all successive keys separated
with a slash (C</>), like in:

    # Our configuration looks like this (YAML):
    x: 42
    A:
        a: 1
        b: 2

    # To get 42:
    Mistress->config->get('x');

    # To get 2:
    Mistress->config->get('A/b');

If you ask for a non-terminal value (like C<A> in our previous example), well,
you will get the hashref below C<A>; but not the original! You will get a
I<cloned> hashref, so that configuration data never change (until you call
C<load>, of course). So, if you call C<get> without arguments (or with an
empty string), you'll get a copy of the whole configuration hashref.

If you specify an unknown key somewhere in your specification string, C<get>
returns C<undef> and logs that (at I<notice> level).

=cut

sub get {
    my $self = shift;
    my $spec = shift // return clone($self->_config);
    my @keys = split qr{ / }x, $spec;
    my $c = $self->_config;
    my $parent = '_(root)_';
    while ( my $node = shift @keys ) {
        unless ( exists $c->{$node} ) {
            $log->notice( "Mistress::Config::get: no '$node' "
                  . "under '$parent', returning undef" );
            return undef;
        }
        $c = $c->{$node};
        return $c unless ref $c eq 'HASHREF';
        $parent = $node;
    }
    return clone($c);
}

1;
