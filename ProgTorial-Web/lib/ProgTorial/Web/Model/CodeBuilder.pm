package ProgTorial::Web::Model::CodeBuilder;

use strict;
use warnings;

use Path::Class;
use base 'Catalyst::Model::Factory::PerRequest';

__PACKAGE__->config( class => 'Safe::CodeBuilder');

sub prepare_arguments {
    my ($self, $c) = @_;

    if(!$c->user) {
        die "Somehow tried to create a CodeBuilder when no user is logged in..";
    }

    my $args = {
        username => $c->user->username,
        project => $c->session->{current_project} || '',
        projects_dir => $c->config->{projects_path},
        environments_dir => $c->config->{env_path},
    };

#    $c->log->_dump($args);

    return $args;
}

1;
