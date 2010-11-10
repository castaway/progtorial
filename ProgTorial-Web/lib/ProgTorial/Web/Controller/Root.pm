package ProgTorial::Web::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(
    namespace => '',
);

=head1 NAME

ProgTorial::Web::Controller::Root - Root Controller for ProgTorial::Web

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('/navigation');
    $c->log->_dump($c->session);
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

## Should store these in a hash/ref, condition/uri, args, name?
sub navigation : Private {
    my ($self, $c) = @_;

    my $nav = [];
    if ($c->user_exists) {
        push @$nav, { url => $c->uri_for('/logout'), name => 'Logout' };
        push @$nav, { url => $c->uri_for($c->controller('User')->action_for('view_profile'), [ $c->user->username ]), name => 'Your page'};

        for my $bookmark ($c->user->obj->bookmarks) {
            # FIXME: Let these be styled?
            my $url = $c->uri_for($c->controller('Chapter')->action_for('chapter_index'), [ $bookmark->tutorial->tutorial, $bookmark->chapter ]);
            my $name = $bookmark->tutorial->tutorial . ' - ' .$bookmark->chapter;
            push @$nav, { url => $url, name => $name };
        }
    } else {
        push @$nav, { url => $c->uri_for('/users/login'), name => 'Login' };
    }

    push @$nav, { url => $c->uri_for('/tutorials'), name => 'Tutorials' };

    $c->stash(navigation => $nav,
              current_page => $c->req->uri,
             );
}

## Display markdown "pages" (for now..)
sub page : Local :Args(1) {
    my ($self, $c, $page) = @_;

    if($page && $c->config->{pages_path}->file("$page.md")) {
        $c->stash(page => ''.$c->config->{pages_path}->file("$page.md")->slurp);
    }

    $c->forward('/navigation');
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
