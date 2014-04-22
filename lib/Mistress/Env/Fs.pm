package Mistress::Env::Fs;
# ABSTRACT: How other Mistress components access the filesystem.

our $VERSION = '0.001'; # VERSION

use Moo::Role;
with 'Mistress::Env';

use namespace::clean;


sub component_name { 'fs' }

BEGIN {
    for my $prefix (qw/ path conf /) {
        for my $method (qw/ openr openw slurp spew dump load /) {
            requires "${prefix}_${method}";
        }
    }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mistress::Env::Fs - How other Mistress components access the filesystem.

=head1 VERSION

version 0.001

=head1 SYNOPSIS

    # Read/write:
    my $fh   = Mistress->fs->path_openr($path);    # open for reading
    my $fh   = Mistress->fs->path_openw($path);    # open for writing
    my $text = Mistress->fs->path_slurp($path);    # get all content
    Mistress->fs->path_spew( $path, $text );       # replace content with $text

    # Serialize/deserialize
    Mistress->fs->path_dump( $path, $data );       # serialize $data in $path
    my $data = Mistress->fs->path_load($path);     # deserialize $path in $data

    # You can do the same with $path being in the configuration file:
    my $fh   = Mistress->fs->conf_openr($key);
    my $fh   = Mistress->fs->conf_openw($key);
    my $text = Mistress->fs->conf_slurp($key);
    Mistress->fs->conf_spew( $key, $text );
    Mistress->fs->conf_dump( $key, $data );
    my $data = Mistress->fs->conf_load($key);

=head1 DESCRIPTION

Mistress::Env::Fs is a role for environment components which provide
facilities to access the underlying filesystem.
Thus, code is shorter and tests are easier!

This role addresses two common tasks:

=over 4

=item *

reading text from a file, or writing text to a file;

=item *

loading serialized data from a file, or serializing data to a file.

=back

Because many filenames are not hardcoded (or definitely I<should> not), each
Mistress::Env::Fs function comes in two flavors: one working with paths
(method name beginning with C<path_>), and the other working with
configuration keys (method name beginning with C<conf_>), the latter
implicitely calling Mistress->config->get to get a path.

=head1 AUTHOR

Thibaut Le Page <thilp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Thibaut Le Page.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
