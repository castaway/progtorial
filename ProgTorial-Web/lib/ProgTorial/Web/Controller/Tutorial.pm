package ProgTorial::Web::Controller::Tutorial;
use Moose;
use namespace::autoclean;

use Config::Any::JSON;

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

    ## $c->model('Tutorials')->all->config, or something !?

    $c->forward('/navigation');

    my @tutorials  =  map { 
        print STDERR "Opening $_\n";
        +{
          capture => $_->dir_list(-1, 1),
          chapters => $self->get_chapters($_),
          %{
              Config::Any::JSON->load($_->file('config.cfg'))
            }
         }
    } $c->config->{tutorial_path}->children;
    $c->stash(tutorials => \@tutorials);
}

sub tutorial :Chained('tutorial_base') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $tutorial) = @_;

    ## Untaint!
    $tutorial =~ s/[^\w-]//g;

    my $tutorial_path = $c->config->{tutorial_path}->subdir($tutorial);

    if(!-d $tutorial_path) {
        print STDERR "Can't find tutorial in path, redirecting..";
        print STDERR $tutorial_path, "\n";
        die "FIXME: This is quite broken";
        return $c->res->redirect($c->uri_for($self->action_for('tutorial_index')));
    }

    ## Debugging issues with $c->go .. 
#    $c->log->debug("Tutorial passed in capture: $tutorial");
#    $c->log->debug("Tutorial paath: $tutorial_path");
    $c->stash(tutorial_path => $tutorial_path);
    $c->stash(tutorial => $tutorial_path->dir_list(-1, 1));
    $c->log->debug("stashed tutorial: " . $c->stash->{tutorial});
}

## This might be overkill.. ;)
sub tutorial_end :Chained('tutorial') :PathPart('') :Args(0) {
    my ($self, $c) = @_;
}

sub get_chapters {
    my ($self, $tutorial_dir) = @_;

    ## *.md? 
    my @chapters = grep { /\.md$/ } $tutorial_dir->children;
    return [ map { 
        my $f = $_->stringify; 
        $f =~ s/\.md/\.cfg/; 
        -e $f ? Config::Any::JSON->load($f) : ()
      } @chapters ];
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
