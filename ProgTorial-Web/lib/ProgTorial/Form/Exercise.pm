package ProgTorial::Form::Exercise;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+name' => ( default => 'exercise_form' );

has_field 'exercise' => ( type => 'Hidden', required => 1);
has_field 'answer'   => ( type => 'TextArea', required => 1,
                          label => '',
                          cols => 27,
                          rows => 20,
                          required_message => 'Don\'t forget to add some code!'
    );
has_field 'submit' => ( type => 'Submit', value => 'Compile and Test');

no HTML::FormHandler::Moose;

1;
