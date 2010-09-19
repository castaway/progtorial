package ProgTorial::Web::Controller::Chapter;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

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

    my $chapter_file = $self->find_chapter($chapter);
    
    ## Catch random rubbish in url and send back to start.
    if($chapter_file) {
        $c->stash(current_chapter => $chapter_file);
    } else {
        return $c->res->redirect($c->uri_for('/'));
    }
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
=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
