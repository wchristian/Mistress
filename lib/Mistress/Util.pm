package Mistress::Util;
# ABSTRACT: Often-used basic functions for Mistress;

use strict;
use warnings;

use Carp 'confess';
use Path::Class;
use Safe::Isa;

use parent 'Exporter';
our @EXPORT_OK = qw{
    pcf_from
};

# VERSION

=head1 SYNOPSIS

    use Mistress::Util qw/ pcf_from /;

    my $file = pcf_from($dubious);

=head1 DESCRIPTION

This class exports (on request) short functions implementing things I find
myself re-implementing again and again in other classes. Hopefully
Mistress::Util will save me some keystrokes and make my sources more readable.

=head1 FUNCTIONS

=cut

=head2 pcf_from( $file )

Converts C<$file> into a L<Path::Class::File> if C<$file> is a
Path::Class::File object or a string that can be converted using
C<Path::Class::file()>; otherwise dies with a backtrace.

=cut

sub pcf_from {
    my $file = shift;
    unless ( $file->$_isa('Path::Class::File') ) {
        defined $file
          or confess "Can't Path::Class::File-ize undef";
        !ref $file
          or confess "Can't Path::Class::File-ize a reference";
        $file = file($file);
    }
    return $file;
}

1;
