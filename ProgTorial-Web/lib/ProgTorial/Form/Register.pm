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
has_field 'password' => ( type => 'Password', label => 'password',
                             required => 1, required_message => 'Please enter a password',
    );
has_field 'password2' => ( type => 'Password', label => 'password (again)',
                             required => 1, required_message => 'Please enter a password',
    );
has_field 'email' => ( type => 'Email', label => 'email', required => 1,
                          required_message => 'Please enter your email address',
    );

has_field 'register' => ( type => 'Submit', value => 'Register' );

has '+dependency' => ( default => sub {
    [
     [ 'password', 'password2'],
    ]
                       }
    );

no HTML::FormHandler::Moose;

1;

