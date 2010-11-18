package ProgTorial::Web::Controller::User;
use Moose;
use namespace::autoclean;

BEGIN {extends 'CatalystX::SimpleLogin::Controller::Login'; }

use ProgTorial::Form::Register;
use ProgTorial::Form::Profile;

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

sub view_profile :Chained('user_base') :PathPart('profile') :Args(1) {
    my ($self, $c, $user) = @_;

    if($c->user_exists && $user eq $c->user->username) {
        $c->go('view_own_profile');
    } else {
        $c->forward('view_foreign_profile', [$user]);
    }
}

sub view_own_profile :Private {
    my ($self, $c) = @_;

    ## Nothing yet?
    ## Pull current tutorials/exercises/completed exercises from DB etc.

    $c->forward('get_status_updates', [$c->user->obj]);
}

sub view_foreign_profile :Private {
    my ($self, $c, $username) = @_;

    ## Nothing yet?
    ## Pull current tutorials/exercises/completed exercises from DB etc.

    my $user = $c->model('Database::User')->find({ username => $username });
    die "No such user $username" if(!$user);

    $c->forward('get_status_updates', [$user]);
    $c->stash(user => $user);
}

sub edit_profile :Chained('user_base') :PathPart('edit_profile') {
    my ($self, $c) = @_;

    ## Should probably ::Form::User::Profile
    my $form = ProgTorial::Form::Profile->new();

    foreach my $col (qw/username email/) {
        $form->field($col)->value($c->user->obj->$col);
    }
    if($c->req->param()) {
        $form->process(ctx => $c, params => $c->req->params, verbose => 1 );
        if($form->validated) {
            $c->log->info('Updating user account');

            ## How to return/set form to error state if update fails?
            my %values = map { exists $c->req->params->{$_} 
                               ? ($_ => $c->req->param($_)) 
                                   : ()} qw/password email/;
            $c->user->obj->update(\%values);

            ## Privacy settings
            $c->user->obj->settings->delete;
            foreach my $setting(qw/show_bookmarks show_exercises/) {
                $c->user->obj->settings->create({ 
                    setting => {
                        name => $setting,
                    },
                    value => 1,
                                                })
            }
            
        }
    }

    $c->stash(form => $form);
}


## Get latest bookmarks/pages read/exercises attempted
## For all users, or just given one.
sub get_status_updates : Private {
    my ($self, $c, $user) = @_;

    my $bookmarks = $c->model('Database::Bookmark')->search({
        ( $user ? (user_id => $user->id) : () )
       },
       {
           select => [ 'user_id', 'occurred_on', \"'bookmarked ' || chapter || ' in ' || tutorial AS status " ],
           as     => [ 'user_id', 'occurred_on', 'status'],
       });

    my $exercises = $c->model('Database::Solution')->search({
        ( $user ? (user_id => $user->id) : () )
       },
       {
           select => [ 'user_id', 'occurred_on', \"'attempted ' || exercise || ' in ' || tutorial || ', and collected a ' || status || ' result' AS status" ],
           as     => [ 'user_id', 'occurred_on', 'status'],
       });
    

    $bookmarks->result_class('ProgTorial::Database::Result::Status');
    $exercises->result_class('ProgTorial::Database::Result::Status');
    my $updates = $bookmarks->union($exercises)->search({},
                                         {
                                             prefetch => ['user'],
                                             order_by => ['occurred_on desc'],
                                             rows => 10,
                                         });

    $c->stash(status_updates => $updates);

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
        $form->process(ctx => $c, params => $c->req->params, verbose =>  0);
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
