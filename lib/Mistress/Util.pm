package Mistress::Util;
# ABSTRACT: Often-used basic functions for Mistress;

use strict;
use warnings;

use Carp 'confess';
use Path::Class;
use Safe::Isa;

use parent 'Exporter';
our @EXPORT_OK = qw{
    pcf  pcf_e  pcf_r  pcf_w
    conf2file
};

# VERSION

=head1 SYNOPSIS

    use Mistress::Util qw/ pcf pcf_r pcf_w /;

    my $pcf = pcf($foo);      # get a Path::Class::File or dies
    my $pcf = pcf_e($foo);    # idem, but also dies unless $foo exists
    my $pcf = pcf_r($foo);    # idem, but also dies unless $foo is readable
    my $pcf = pcf_w($foo);    # idem, but also dies unless $foo is writable

    # Build a Path::Class::File by specifying a path after a configuration key
    my $stats_file = conf2file('Mistress/workdir', qw/ log stats.txt /);

=head1 DESCRIPTION

This class exports (on request) short functions implementing things I find
myself re-implementing again and again in other classes. Hopefully
Mistress::Util will save me some keystrokes and make my sources more readable.

=head1 FUNCTIONS

=cut

=head2 pcf( $file ), pcf_e( $file ), pcf_r( $file ), pcf_w( $file )

Converts C<$file> into a L<Path::Class::File> if C<$file> is a
Path::Class::File object or a string that can be converted using
C<Path::Class::file()>; otherwise dies.

Additionally, C<pcf_e>, C<pcf_r> and C<pcf_w> die if C<$file> fails the
corresponding C<-X> test (i.e. C<-e>, C<-r> or C<-w>).

=cut

sub pcf {
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

sub pcf_e {
    my $file = pcf(shift());
    $file->stat or confess "$file does not exist";
    return $file;
}

sub pcf_r {
    my $file = pcf_e(shift());
    -r $file->stat or confess "$file is not readable";
    return $file;
}

sub pcf_w {
    my $file = pcf_e(shift());
    -w $file->stat or confess "$file is not writable";
    return $file;
}

=head2 conf2file( $key, @subpath )

Get the configuration value corresponding to C<$key>, interpret it as a
L<Path::Class::Dir> and append C<@subpath> to it to make a
L<Path::Class::File> which is returned.

Dies if C<$key> as no associated configuration value
(C<< Mistress->config->get >> returns C<undef>).

=cut

sub conf2file {
    my $key    = shift;
    my $parent = Mistress->config->get($key)
      or confess qq{No configuration value associated to "$key"};
    return file( $parent, @_ );
}

1;
