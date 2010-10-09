package ProgTorial::Web::Controller::User;
use Moose;
use namespace::autoclean;

BEGIN {extends 'CatalystX::SimpleLogin::Controller::Login'; }

## Ideally this should eventually be both login+register, 
## see amazon + qype for inspiration
use ProgTorial::Form::Register;

=head1 NAME

ProgTorial::Web::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched ProgTorial::Web::Controller::User in User.');
}

## ??
sub auth_user : Local Does('NeedsLogin') {
    my ( $self, $c ) = @_;
    $c->res->body('<h2>Hello, user!</h2>');
}

sub view_profile :Chained('required') :PathPart('profile') :Args(1) {
    my ($self, $c, $user) = @_;

    if($user eq $c->user->username) {
        $c->go('view_own_profile');
    } else {
        $c->forward('view_foreign_profile', $user);
    }
}

sub view_own_profile :Private {
    my ($self, $c) = @_;

    ## Nothing yet?
    ## Pull current tutorials/exercises/completed exercises from DB etc.
}

## Used by Catalyst::ActionRole::NeedsLogin
sub login_redirect {
    my ($self, $ctx) = @_;
    $ctx->response->redirect($ctx->uri_for($self->action_for('register_or_login')));
    $ctx->detach;
}

sub register_or_login :Chained('not_required') :PathPart('login') :Args(0) {
    my ($self, $c) = @_;

    my $form = ProgTorial::Form::Register->new();
    if($c->req->param()) {
        $form->process(ctx => $c, params => $c->req->params, verbose => 1 );
        ## Register, else authenticated by validate()
        if($form->validated) {
            if($form->field('is_register')->value) {
                my $user_rs = $c->model('Database::User');
                $user_rs->create( { 
                    ( map { $user_rs->result_source->has_column($_) ? ($_, $c->req->param($_)) : () }
                      keys %{ $c->req->params}),
                    displayname => $c->req->param('username')});
                # $c->res->redirect($c->uri_for('/'));
            }

            $c->res->redirect($c->session->{redirect_to_after_login});
            $c->extend_session_expires(999999999999)
                if $form->field( 'remember' )->value;

        }
    }

    $c->stash(form => $form);

} 


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
