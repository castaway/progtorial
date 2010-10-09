package ProgTorial::Web::Controller::Chapter;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use ProgTorial::Form::Exercise;
use Config::Any::JSON;

has 'pages_path' => (is => 'rw', isa => 'Path::Class::Dir', required => 1);
# has 'env_path' => (is => 'rw', isa => 'Path::Class::Dir', required => 1);

=head1 NAME

ProgTorial::Web::Controller::Chapter - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub base :Chained('/tutorial/tutorial') :PathPart('chapter') :CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->forward('/navigation');

#    $c->log->_dump($self->get_chapter_configs);
    my @chapter_nav = map { { url => $c->uri_for( 
                                  $self->action_for('chapter_index'), 
                                  [$_->{chapter}]
                                  ),
                                  name => $_->{chapter} }
    }
    (sort { $a->{order} <=> $b->{order} } $self->get_chapter_configs($c->stash->{tutorial}));

    push @{$c->stash->{navigation}}, @chapter_nav;
}

# id chain, current chapter /chapter/X
sub chapter :Chained('base') :PathPart(''): CaptureArgs(1) {
    my ($self, $c, $chapter) = @_;

    ## <chapter>.md
    $c->log->_dump($c->stash);
    my $chapter_file = $self->find_chapter($c->stash->{tutorial}, $chapter);
    
    ## Catch random rubbish in url and send back to start.
    if($chapter_file) {
        $c->stash(current_chapter => $chapter_file);
    } else {
        return $c->res->redirect($c->uri_for('/'));
    }

    ## <chapter>.cfg
    my $config = $self->find_config($chapter_file);
    $c->stash(config => $config);
    $c->stash(exercises => $self->load_exercises($c, $config, $chapter));

    if($c->session_expires(1)) {
        ## Store current project associated with this chapter, to send to
        ## CodeBuilder when on exercise submission
        $c->session(current_project => $config->{distribution});

        ## Where should this go?
        if($c->user_exists) {
            $c->model('CodeBuilder')->create_environment_directory();
        }
    }

    $c->stash(login_invite => sub { 
        my $exercise = shift; 
        my $here = $c->req->uri;
        $here->fragment($exercise);

        ## Somehow this fails to redirect.. 
        $c->session->{redirect_to_after_login} = $here->as_string;
        $c->log->_dump($c->session);

#        $c->stash(template => 'exercise/login_invite.tt');
        return $c->view->render($c, 'exercise/login_invite.tt', {no_wrapper => 1});
              });
}

## Exercise submission
sub exercise :Chained('chapter') :PathPart('exercise') :Args(0) {
    my ($self, $c) = @_;
    
    my $exercise = $c->req->param('exercise');
    if(!exists $c->stash->{exercises}{$exercise}) {
        die "No such exercise $exercise in chapter " . $c->stash->{config}{chapter};
    }

    if(!$c->user_exists) {
        die "Shouldn't be able to get here with no user? (session expired?)";
    }

    my $results = $c->model('CodeBuilder')->compile_project();
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

sub get_chapter_configs {
    my ($self, $pdir) = @_;

    my @chapters = grep { $_->basename =~ /\.md$/ } $pdir->children;

    return map { $self->find_config($_) } @chapters;
}

sub find_chapter {
    my ($self, $tutorial, $chapter) = @_;

#    my $pdir = $self->pages_path;
    if(!-d "$tutorial") {
        die "Chapter path $tutorial not found, configuration error?";
    }
    my $chapter_file = $tutorial->file(lc "$chapter.md");
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

## the uri_for in here is a bit ugly, and its the only reason we pass 
## $c and $chapter !?
## load exercise forms for given config file:
sub load_exercises {
    my ($self, $c, $config, $chapter) = @_;

    return {map {
        print STDERR "Ex: $_\n";
        my $form = ProgTorial::Form::Exercise->new();
        $form->field('exercise')->value($_);
        $form->action($c->uri_for($self->action_for('exercise'), 
                                  [ $chapter ]));
#        print STDERR "Form:", $form->render, "\n";
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
