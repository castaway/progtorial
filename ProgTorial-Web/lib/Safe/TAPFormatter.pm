package Safe::TAPFormatter;
use warnings;
use strict;
use parent 'TAP::Formatter::Base';

sub open_test {
  my ($self, $filename, $parser) = @_;
  print "MyFormatter: open_test filename=$filename, parser=$parser\n";

  # This is supposed to return a "session", which "result" can then be called on.
  $self->{current_filename} = $filename;

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

  if ($result->isa('TAP::Parser::Result::Plan')) {
    # Plans?  We don't need no steenkin plans.
    return;
  }

  my $my_result = {
                   number => $result->number,
                   description => $result->description,
                   directive => $result->directive, # undef, TODO, or SKIP.
                   explanation => $result->explanation, # if directive is TODO or SKIP, why it was TODONE or SKIPped.
                   is_ok => $result->is_ok
                  };
                   

  if (!exists $self->{all_ok}) {
    $self->{all_ok} = 1;
  }
  $self->{all_ok} &&= $result->is_ok;

  push @{$self->{results}{$self->{current_filename}}{results}}, $my_result;

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

