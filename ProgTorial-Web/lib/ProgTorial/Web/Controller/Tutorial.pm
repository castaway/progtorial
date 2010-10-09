package ProgTorial::Web::Controller::Tutorial;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

ProgTorial::Web::Controller::Tutorial - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

# sub index :Path :Args(0) {
#     my ( $self, $c ) = @_;

#     $c->response->body('Matched ProgTorial::Web::Controller::Tutorial in Tutorial.');
# }

sub tutorial_base: Chained('/') :PathPart('tutorials') : CaptureArgs(0) {
}

sub tutorial_index: Chained('tutorial_base') :PathPart('') :Args(0) {
    my ($self, $c) = @_;

    ## List tutorials (+chapters?) here using $c->config('tutorial_path').
}

sub tutorial :Chained('tutorial_base') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $tutorial) = @_;

    ## Untaint!
    $tutorial =~ s/[^\w-]//g;
    if(!-d $c->config->{tutorial_path}->subdir($tutorial)) {
        print STDERR "Can't find tutorial in path, redirecting..";
        print STDERR $c->config->{tutorial_path}->subdir($tutorial), "\n";
        return $c->res->redirect($c->uri_for($self->action_for('tutorial_index')));
    }

    $c->stash(tutorial => $c->config->{tutorial_path}->subdir($tutorial));
    $c->log->debug("stashed: " . $c->stash->{tutorial});
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
