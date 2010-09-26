package ProgTorial::Web::Controller::Chapter;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use ProgTorial::Form::Exercise;
use Config::Any::JSON;

has 'pages_path' => (is => 'rw', isa => 'Path::Class::Dir', required => 1);

=head1 NAME

ProgTorial::Web::Controller::Chapter - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub base :Chained('/') :PathPart('chapter') :CaptureArgs(0) {
}

# id chain, current chapter /chapter/X
sub chapter :Chained('base') :PathPart(''): CaptureArgs(1) {
    my ($self, $c, $chapter) = @_;

    ## chapter.md
    my $chapter_file = $self->find_chapter($chapter);
    
    ## Catch random rubbish in url and send back to start.
    if($chapter_file) {
        $c->stash(current_chapter => $chapter_file);
    } else {
        return $c->res->redirect($c->uri_for('/'));
    }

    ## chapter.cfg
    my $config = $self->find_config($chapter_file);
    $c->stash(exercises => $self->load_exercises($config));


#    $c->stash(load_exercise => sub { my $exercise = shift; return $exercise });
    $c->stash(login_invite => sub { 
        my $exercise = shift; 
        my $here = $c->req->uri;
        $here->fragment($exercise);

        ## Somehow this fails to redirect.. 
        $c->session->{redirect_to_after_login} = $here->as_string;
        $c->log->_dump($c->session);

        $c->stash(template => 'exercise/login_invite.tt');
        return $c->forward($c->view);
              });
}

sub chapter_index :Chained('chapter') :PathPart('') :Args(0) {
    my ($self, $c) = @_;

    ## end chain for plain chapter index, 
    ## do we need this one or just for testing?

    $c->stash(content => scalar $c->stash->{current_chapter}->slurp);
}
 
# sub index :Path :Args(0) {
#     my ( $self, $c ) = @_;

#     $c->response->body('Matched ProgTorial::Web::Controller::Chapter in Chapter.');
# }

sub find_chapter {
    my ($self, $chapter) = @_;

    my $pdir = $self->pages_path;
    if(!-d "$pdir") {
        die "Chapter path $pdir not found, configuration error?";
    }
    my $chapter_file = $pdir->file(lc "$chapter.md");
    if(!-e "$chapter_file") {
        print STDERR "User asked for missing chapter file $chapter_file";
        return undef;
    }

    return $chapter_file;
}

sub find_config {
    my ($self, $chapter_file) = @_;

    die "Non-existant chapter file: $chapter_file" if(!$chapter_file || !-e $chapter_file);
    my $conf = $chapter_file->basename;
    $conf =~ s/\.\w+$/.cfg/;
    my $conf_file = $chapter_file->dir()->file($conf);
    if(!-e "$conf_file") {
        print STDERR "No config file for chapter file $chapter_file";
        return undef;
    }

    return Config::Any::JSON->load("$conf_file");

}

## load exercise forms for given config file:
sub load_exercises {
    my ($self, $config) = @_;

    return {map {
        print STDERR "Ex: $_\n";
        my $form = ProgTorial::Form::Exercise->new(params => { exercise => $_ });
        print STDERR "Form:", $form->render, "\n";;
        ( $_ => $form );
            }
            @{ $config->{exercises} } 
    };
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
