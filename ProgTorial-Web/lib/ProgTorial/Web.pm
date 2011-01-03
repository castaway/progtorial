package ProgTorial::Web;
use Moose;
use namespace::autoclean;

use Path::Class;
use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    +CatalystX::SimpleLogin
    Authentication
    Session
    Session::Store::File
    Session::State::Cookie
    Static::Simple
/;

extends 'Catalyst';

our $VERSION = '0.01';
$VERSION = eval $VERSION;

# Configure the application.
#
# Note that settings in progtorial_web.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'ProgTorial::Web',
    'View::HTML' => {
#        STRICT => 1,
        WRAPPER => 'wrapper.tt',
    },
    ## should be in conf file.
    'tutorial_path' => ProgTorial::Web->path_to('tutorials'),
    pages_path => ProgTorial::Web->path_to('pages'),
    projects_path => Path::Class::Dir->new('/usr/src/perl/progtorial/skeletons/'),
    env_path => Path::Class::Dir->new('/tmp/progtorial_env'),
#    'Controller::User' => { traits => 'Login::OpenID' },
    'Controller::Login' => {
#        traits => ['OpenID'],
#        login_form_class_roles => [ 'CatalystX::SimpleLogin::Form::LoginOpenID'],
    },
    'Plugin::Authentication' => {
        default_realm => 'default',
        realms => { 
            default => {
                credential => {
                    class => 'Password',
                    password_field => 'password',
                    password_type => 'clear',
#                    password_type => 'hashed',
#                    password_hash_type => 'SHA-1',
                },
                store => {
                    class => 'DBIx::Class',
                    user_model => 'DataBase::User',
                    use_userdata_from_session => 0,
                },
            },
            openid => {
                credential => {
                    debug => 1,
                    class => 'OpenID',
#                    errors_are_fatal => 1,
## using LWP::ParanoidAgent (default)                    
#                    ua_class => 'LWP::UserAgent',
                },
                ## openid credential cant use dbic store..
                store => {
#                    class => 'OpenID',
                    class => 'DBIx::Class',
                    user_model => 'DataBase::User',
                    use_userdata_from_session => 0,
                },
            },
        },
    },
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
);

# Start the application
__PACKAGE__->setup();


=head1 NAME

ProgTorial::Web - Catalyst based application

=head1 SYNOPSIS

    script/progtorial_web_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<ProgTorial::Web::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
