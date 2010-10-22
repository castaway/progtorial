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

sub user_base :Chained('not_required') :PathPart('users') :CaptureArgs(0) {
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
    my $redir = $ctx->uri_for($self->action_for('register_or_login') || '/');
    $ctx->response->redirect($redir);
    $ctx->detach;
}

sub register_or_login :Chained('user_base') :PathPart('login') :Args(0) {
    my ($self, $c) = @_;

    my $form = ProgTorial::Form::Register->new();
    if($c->req->param()) {
        $form->process(ctx => $c, params => $c->req->params, verbose => 1 );
        ## Register, else authenticated by validate()
        if($form->validated) {
            $c->log->info('Validated register');
            ## Move all this into the form so that if user create fails
            ## validate fails and user can retry
            if($form->field('is_register')->value) {
                $c->log->info('is Register = true');
                my $user_rs = $c->model('Database::User');
                my $newuser = $user_rs->create( { 
                    ( map { $user_rs->result_source->has_column($_) ? ($_, $c->req->param($_)) : () }
                      keys %{ $c->req->params}),
                    displayname => $c->req->param('username')
                                                });
                if($newuser) {
                    $c->authenticate({ username => $c->req->param('username'),
                                       password => $c->req->param('password') });
                } else {
                    die "Failed to create user";
                }
                ## Where should this go?
                if($c->user_exists && $c->req->param('do_createenv')) {
                    ## No "current project" here? S::CB needs to not care..
                    $c->model('CodeBuilder')->create_environment_directory();
                }
                # $c->res->redirect($c->uri_for('/'));
            } else {
                ## Has logged in:
                my $cb = $c->model('CodeBuilder');
                $cb->create_environment_directory();

## Update env with deps:
## (better handling of deps for project X needed)
                for (grep {$_ =~ /perlbrew/ && -e} @INC) {
#                    print STDERR "Adding INC $_\n";
                    $cb->insert_hardlink($_);
                }
            }
            $c->session->{redirect_to_after_login} ||= $c->uri_for('/');
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
