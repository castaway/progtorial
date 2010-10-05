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

## /login action is included from the base class

sub user_base :Chained('not_required') :PathPart('users') :CaptureArgs(0) {
}

sub register_or_login :Chained('user_base') :PathPart('login') :Args(0) {
    my ($self, $c) = @_;

    my $form = ProgTorial::Form::Register->new();
    if($c->req->param()) {
        $form->process(ctx => $c, params => $c->req->params);
        ## Register, else authenticated by validate()
        if($form->validated && $form->field('is_register')->value) {
            my $user_rs = $c->model('Database::User');
            $user_rs->create( { 
               ( map { $user_rs->result_source->has_column($_) ? ($_, $c->req->param($_)) : () }
                keys %{ $c->req->params}),
               displayname => $c->req->param('username')});
            $c->res->redirect($c->uri_for('/'));
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
