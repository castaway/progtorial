package ProgTorial::Form::Profile;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+name' => ( default => 'profile_form' );

## Localise messages?

## actual profile fields
has_field 'username' => ( type => 'Text', label => 'username', required => 0,
                          unique => 1, unique_message => 'Username already taken' );
has_field 'password' => ( type => 'Password', label => 'password',
                          required => 0,
    );
has_field 'password2' => ( type => 'Password', 
                           label => 'password (again)',
                           required => 0, 
    );
has_field 'email' => ( type => 'Email', 
                       label => 'email', 
                       required => 0,
    );

## settings

has_field 'show_bookmarks' => ( type => 'Checkbox',
                                label => 'Set to display your bookmark updates publically',
                                required => 0
);
has_field 'show_exercises' => ( type => 'Checkbox',
                               label => 'Set to display your exercise attempts publically',
                               required => 0
);


has_field 'save' => ( type => 'Submit', 
                      value => 'Save' );

has '+dependency' => ( default => sub {
    [
     [ 'password','password_2'],
    ]
                       }
    );

no HTML::FormHandler::Moose;

1;

