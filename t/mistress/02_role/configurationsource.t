use Test::Modern -default;

my $classname   = 'Mistress::Role::ConfigurationSource';
my $fakepkgname = 'TestFor::Mistress::Role::ConfigurationSource';

# The following class is a very basic implementation of ConfigurationSource.
eval <<"END_PKG";
{
    package $fakepkgname;
    use Moo;
    with '$classname';
    use MooX::Types::MooseLike::Base 'Str';
    use namespace::clean;

    has where => (
        is       => 'ro',
        isa      => Str,
        required => 1,
    );

    sub same_as { \$_[0]->where eq \$_[1]->where }
}
END_PKG

object_ok(
    $fakepkgname->new( where => 'abc' ),
    isa   => [$fakepkgname],
    does  => [$classname],
    api   => [qw/ new where same_as DOES /],
    clean => 1,
    more  => sub {
        my $obj = shift;
        my $same = $fakepkgname->new( where => 'abc' );
        ok $obj->same_as($same), 'same_as works with same objects';

        {
            my $notsame = { flying => 'totoro' };
            like( exception { $obj->same_as($notsame) },
                qr/same type/, 'same_as dies with non-blessed refs' );
        }

        {
            my $notsame = bless { flying => 'totoro' } => 'Foo';
            like( exception { $obj->same_as($notsame) },
                qr/same type/, 'same_as dies with unrelated classes' );
        }
    },
);

done_testing();
