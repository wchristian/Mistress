package Mistress::App;
# ABSTRACT: Mistress' App::Cmd

use strict;
use warnings;
use App::Cmd::Setup 0.309 -app;

our $VERSION = '0.001'; # VERSION


sub usage_desc {
    $_[0]->full_arg0 . ' <command> -c <path> [options...] [args...]';
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mistress::App - Mistress' App::Cmd

=head1 VERSION

version 0.001

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Thibaut Le Page <thilp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Thibaut Le Page.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
