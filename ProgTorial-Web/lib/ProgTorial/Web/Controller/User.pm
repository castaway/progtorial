package ProgTorial::Web::Controller::User;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::ActionRole'; }

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

sub auth_user : Local Does('NeedsLogin') {
    my ( $self, $c ) = @_;
    $c->res->body('<h2>Hello, user!</h2>');
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
