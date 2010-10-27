package Safe::TAPFormatter;
use warnings;
use strict;
use parent 'TAP::Formatter::Base';

sub _initialize {
  my ($self) = @_;
  TAP::Formatter::Base->can('_initialize')->(@_);
  $self->{all_ok} = 1;

  return $self;
}

sub open_test {
  my ($self, $filename, $parser) = @_;
  print "MyFormatter: open_test filename=$filename, parser=$parser\n";

  # This is supposed to return a "session", which "result" can then be called on.
  $self->{current_filename} = $filename;
  $self->{files}{$filename} ||= {};

  return $self;
}

sub close_test {
  my ($self) = @_;

  $self->{current_filename} = undef;

  return $self;
}

sub result {
  my ($self, $result) = @_;

  # result is a TAP::Parser::Result::Test

  warn "Collecting result $result";

  my $file_thing = $self->{files}{$self->{current_filename}};

  my $my_result = {
                   as_string => $result->as_string,
                   type => $result->type,
                  };
  if ($result->is_plan) {
    $my_result->{is_ok} = 1;
    $file_thing->{planned_test_count} = $result->tests_planned;
  } elsif ($result->is_bailout) {
    $my_result->{is_ok} = 0;
  } elsif ($result->is_test) {
    $my_result = {
                  number => $result->number,
                  description => $result->description,
                  directive => $result->directive, # undef, TODO, or SKIP.
                  explanation => $result->explanation, # if directive is TODO or SKIP, why it was TODONE or SKIPped.
                  is_ok => $result->is_ok,
                  as_string => $result->as_string,
                 };
  } elsif ($result->type eq 'unknown') {
    # Everything useful in here is universal.
  } elsif ($result->type eq 'comment') {
    $my_result->{text} = $result->comment;
  } else {
    die "don't know how to handle result $result";
  }

  $file_thing->{all_ok} &&= $my_result->{is_ok};
  $self->{all_ok}       &&= $my_result->{is_ok};

  push @{$file_thing->{results_ordered}}, $my_result;
  $file_thing->{results_named}{$my_result->{description}} = $my_result
    if $my_result->{description};

  return 1;
}

sub summary {
    my ($self, $aggregate, $interrupted) = @_;

    warn "Collecting summary";

    $self->{all_ok} = 0 if($interrupted);
    $self->{total} = $aggregate->total;
    $self->{passed} = $aggregate->passed;
    $self->{runtime} = $aggregate->elapsed_timestr;

    return $self->SUPER::summary($aggregate, $interrupted);
}

sub TO_JSON {
  my ($self) = @_;

  my $copy = {%$self};
  delete $copy->{stdout};

  return $copy;
}

#sub DESTROY {
#}

#sub AUTOLOAD {
#  our $AUTOLOAD;
#  die "MyFormatter::AUTOLOAD: $AUTOLOAD(@_)";
#}

1;

