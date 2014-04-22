package Mistress::Role::DistGatherer;
# ABSTRACT: A role for plugins that construct L<Mistress::Obj::Dist> objects.

use Moo::Role;
use MooX::Types::MooseLike::Base qw( ArrayRef )
use Mistress::Obj::Dist;

our $VERSION = '0.001'; # VERSION


requires 'build_dists';

has dists => (
    is      => 'rwp',
    isa     => ArrayRef['Mistress::Obj::Dist'],
    lazy    => 1,
    builder => 'build_dists',
);

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mistress::Role::DistGatherer - A role for plugins that construct L<Mistress::Obj::Dist> objects.

=head1 VERSION

version 0.001

=head1 SYNOPSIS

Say I want Mistress to test distributions coming from Darcs:

    package Mistress::Plugin::GatherFromDarcs;
    use Moo;
    use namespace::clean;

    with 'Mistress::Role::DistGatherer';

    sub build_dists {
        # Darcs-related stuff here
        return \@my_dists; # arrayref of Mistress::Obj::Dist objects
    }

This C<Mistress::Plugin::GatherFromDarcs> would be automatically called during
the creation of the L<Mistress::Obj::DistSet> (by
L<Mistress::Command::consider>).

=head1 DESCRIPTION

L<Mistress::Obj::DistSet> gets its L<Mistress::Obj::Dist> objects by calling
the C<dists> method of all plugins (under C<Mistress::Plugin::>) that consume
the Mistress::Role::DistGatherer role. C<dists> being a lazy attribute, that
call triggers the C<build_dists> method, which is B<required> by this role.

=head1 AUTHOR

Thibaut Le Page <thilp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Thibaut Le Page.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
