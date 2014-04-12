package Mistress::App;
# ABSTRACT: Mistress' App::Cmd

use strict;
use warnings;
use App::Cmd::Setup 0.309 -app;

# VERSION

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

sub usage_desc {
    $_[0]->full_arg0 . ' <command> -c <path> [options...] [args...]';
}

1;
