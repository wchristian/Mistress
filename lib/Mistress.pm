package Mistress;
# ABSTRACT: A simple but extensible Perl dist tester.

# VERSION

use Log::Any '$log';
use Package::Stash;
use Mistress::Env::Config::Base;

use namespace::clean;

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

### Setup environment components from the configuration file

sub _load_config {
    my $config_file = shift;
    my %envs;

  LOADING: {
        my $config = $envs{config} // Mistress::Env::Config::Base->new;
        $config->load($config_file);
        my $env_config = $config->get('Mistress/environments');
        if ( defined $env_config ) {
            while ( my ( $k, $v ) = each %$env_config ) {
                my $class  = "Mistress::Env::$v";
                my $errstr = qq{$config_file mentions "$k: $v" but I };

                # Check that we can load $class
                eval { eval "require $class"; 1 } or do {
                    $log->error( $errstr . "can't load $class: $@" );
                    next;
                };
                eval "require $class";

                # Check that $class does the Mistress::Env role
                $class->DOES('Mistress::Env') or do {
                    $log->error( $errstr
                          . "see $class DOES not the Mistress::Env role" );
                    next;
                };

                # Check that we're registering $class with the name it expects
                my $env_name = &{"${class}::env_name"};
                $env_name eq $k or do {
                    $log->error( $errstr
                          . "see $class expects to be registered as "
                          . qq{"$env_name" whereas you tried to register it as "$k"}
                    );
                    next;
                };

                # Check that we can actually get an instance from $class
                my $obj = eval { $class->new } or do {
                    $log->error( $errstr . "couldn't instantiate $class: $@" );
                    next;
                };

             # All good, prepare to install $obj as Mistress' static member "$k"
                $envs{$k} = $obj;
            }
        }

        # Set defaults if not set yet
        $envs{config} //= 'Config::Base';
        $envs{fs}     //= 'Fs::Disk';

        # (Re-)install symbols in __PACKAGE__
        my $pkg = Package::Stash->new(__PACKAGE__);
        while ( my ( $name, $obj ) = each %$envs ) {
            my $symbol = '&' . $name;
            $pkg->remove_symbol($symbol) if $pkg->has_symbol($symbol);
            $pkg->add_symbol( $symbol, sub { $obj } );
        }

        # Reload configuration if the config component has changed
        goto LOADING if $config ne $envs{config};
    }
}


1;
