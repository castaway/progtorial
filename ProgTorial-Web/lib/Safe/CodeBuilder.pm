package Safe::CodeBuilder;
use Moose;
use MooseX::StrictConstructor;
use Module::CoreList;

has 'username',         is => 'ro';
has 'project',          is => 'ro';
has 'projects_dir',     is => 'ro';
has 'environments_dir', is => 'ro';

sub environment_directory {
  my ($self) = @_;

  return $self->environments_dir->subdir($self->username, $self->project);
}

sub create_code_directory {
  my ($self) = @_;

  $self->create_environment_directory;
}

sub create_environment_directory {
  my ($self) = @_;

  my $dest = $self->environment_directory;
  $dest->mkpath;
  
  for (which('perl'),
       '/bin/bash',
       '/bin/sh',
       '/usr/bin/make',
       '/dev/null',
       '/dev/urandom',
       pm_file('Config')->parent->file('Config_heavy.pl'),
       pm_file('Config')->parent->file('Config_git.pl'),
       (map {pm_file($_)}
        grep {!($_ ~~ ['Time::Piece::Seconds', 'XS::APItest', 'DCLsym', 'Unicode', 'CGI::Fast', qr/Win32/])}
        keys %{$Module::CoreList::version{$]}}
       )) {
    $self->insert_hardlink($_);
  }
}

sub insert_hardlink {
  my ($self, $src) = @_;
  
  if (!ref $src) {
    $src = Path::Class::File->new($src);
  }
  # We want to keep ".." from showing up, but we don't want to get the "real" name of symlinks.
  $src =~ s![^/]+/\.\./!/!;
  $src = Path::Class::File->new($src)->cleanup;
  
  my $dest = Path::Class::File->new($self->environment_directory, "$src");
  return if -e $dest;
  # print "$src -> $dest\n";
  
  $dest->parent->mkpath;
  
  if (!-e $src) {
    die "$src doesn't exist!";
  } elsif (-d $src) {
    $src = Path::Class::Dir->new($src);
    Path::Class::Dir->new($dest)->mkpath;
    $self->insert_hardlink($_) for $src->children;
  } elsif (-c $src) {
    my @args = ('mknod',
                '--mode' => sprintf("0%o", 0777 & $src->stat->mode),
                $dest,
                'c',
                # This math is linux-specific
                $src->stat->rdev >> 8,
                $src->stat->rdev & 0xFF);
    print join(" ", @args), "\n";
    system @args;
  } elsif (-f $src) {
    
    #print "$src magic: $magic\n";
    if (-l $src) {
      my $to = Path::Class::File->new($src->parent, readlink($src));
      if (!-e $to) {
        print "symlink $src is broken, leaving it broken!\n";
      } else {
        # print "$src -> $to\n";
        $self->insert_hardlink($to);
      }
    }
    
    if (!-l $src and $src !~ m/\.pm$/) {
      warn "Getting magic for $src";

      my $magic = `file $src`;
      chomp $magic;
      
      if ($magic =~ m/dynamically linked/) {
        my $ldd = `ldd $src`;
        for my $line (split /\n/, $ldd) {
          if ($line =~ m/statically linked/) {
            next;
          } elsif ($line =~ m/ => (.*) \(0x/) {
            $self->insert_hardlink($1);
          } elsif ($line =~ m!^\s*(/.*) \(0x!) {
            $self->insert_hardlink($1);
          } else {
            die "Don't know what to do for ldd line '$line' from $src";
          }
        }
      }
    }
    
    link($src, $dest) or die "Can't make link from $src to $dest: $!";
  } else {
    die "$src isn't a directory, char dev, or file";
  }
}

# sub, not method
# NB: You can call Path::Class methods on the result only for modules with no "auto" bits, and
# it will give poor error messages if it fails.
sub pm_file {
  my ($classname) = @_;
  if ($classname !~ m/\.pl$/) {
    $classname =~ s!::!/!g;
    $classname .= ".pm";
  }

  for (@INC) {
    my $filename = "$_/$classname";
    if (-e $filename) {
      # Used by autosplit and XS modules.
      my $autoname = "$_/auto/$classname";
      $autoname =~ s/\.pm$//;
      if (-e $autoname) {
        return ($filename, $autoname);
      }
      return Path::Class::File->new($filename);
    }
  }

  return ();
}

# sub, not method
sub which {
  my $x = shift;
  my $foo = `which $x`;
  chomp $foo;
  return $foo;
}


1;
