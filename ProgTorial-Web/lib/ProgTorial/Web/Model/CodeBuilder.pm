package ProgTorial::Web::Model::CodeBuilder;

use strict;
use warnings;

use Path::Class;
use base 'Catalyst::Model::Factory';

__PACKAGE__->config( class => 'Safe::CodeBuilder');

sub prepare_arguments {
    my ($self, $c) = @_;

    if(!$c->user) {
        die "Somehow tried to create a CodeBuilder when no user is logged in..";
    }

    return {
        username => $c->user->username,
        project => $c->session->{current_project},
        project_dir => Path::Class::Dir->new($c->config->{projects_dir}),
        
    };
}

1;
