package Mistress::App::Command::lol;
# ABSTRACT: LOL

use 5.012;

our $VERSION = '0.001'; # VERSION

use Mistress::App -command;
use Mistress;


sub execute {
    say Mistress->config->get('Mistress/environments/config');
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mistress::App::Command::lol - LOL

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
