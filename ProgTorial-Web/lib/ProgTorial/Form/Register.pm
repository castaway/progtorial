package ProgTorial::Form::Register;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+name' => ( default => 'register_form' );

## Localise messages?
has_field 'username' => ( type => 'Text', label => 'username', required => 1,
                          required_message => 'Please enter a username',
                          unique => 1, unique_message => 'Username already taken' );
has_field 'is_openid' => ( type => 'Checkbox',
                           css_class => 'openid_switch login_field',
                           label => 'Login via OpenID'
    );
has_field 'password' => ( type => 'Password', label => 'password',
                          css_class => 'local_login_field',
#                          required => 1, required_message => 'Please enter a password',
    );
has_field 'remember' => ( type => 'Checkbox',
                          css_class => 'login_field',
                          label => 'Remember me'
    );
has_field 'is_register' => ( type => 'Checkbox', 
                             css_class => 'register_switch',
                             label => 'Register new user');

has_field 'password2' => ( type => 'Password', 
                           css_class => 'register_field local_login_field',
                           label => 'password (again)',
#                           required => 1, 
                           required_message => 'Please enter a password',
    );
has_field 'email' => ( type => 'Email', 
                       css_class => 'register_field',
                       label => 'email', 
#                       required => 1,
                       required_message => 'Please enter your email address',
    );

has_field 'do_createenv' => (type => 'Checkbox',
#                           css_class => 'register_field',
                           label => 'Create coding environment'
    );


has_field 'register' => ( type => 'Submit', 
                          css_class => 'register_submit',
                          value => 'Login' );

has '+dependency' => ( default => sub {
    [
     ## If one of these has a value, all are required -> register, not login
     [ 'password_2', 'email', 'is_register'],
    ]
                       }
    );

sub validate {
    my $self = shift;

    if($self->field('is_register')->value) {
        print STDERR "is_register true!\n";
        return $self->next::method(@_);
    }

    my @auth_args = (
        {
            username => $self->field('username')->value,
            password => $self->field('password')->value,
        }
        );

    if($self->field('is_openid')->value) {
        @auth_args = ( { openid_identifier => $self->field('username')->value }, 'openid');
    } elsif( $self->ctx->req->params->{'openid-check'} ) {
        ## grrr
        @auth_args = ( {}, 'openid');
    }

    use Data::Dumper;
    print STDERR 'Auth args:', Data::Dumper::Dumper(\@auth_args);

    unless (
        $self->ctx->authenticate(@auth_args)
    ) {
        $self->field( 'password' )->add_error( 'Wrong username or password' )
            if $self->field( 'username' )->has_value && $self->field( 'password' )->has_value;
        return;
    }
    return 1;
}

no HTML::FormHandler::Moose;

1;

