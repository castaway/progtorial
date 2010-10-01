package Safe::CodeBuilder;
use Moose;
use MooseX::StrictConstructor;
use Module::CoreList;
use Archive::Extract;

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
  $self->extract_archive($self->projects_dir->file($self->project.'-0.01.tar.gz'));
}

sub run_in_child {
  my ($self, @command) = @_;

  my $envdir = $self->environment_directory;

  local $ENV{LANG} = 'C';
  return `sudo chroot --userspec 10005:10012 "$envdir" sh -c '@command'`;
}

sub compile_project {
  my ($self) = @_;
  
  $self->run_in_child('cd /MyBlog-Schema-0.01/; perl Makefile.PL');
}

sub extract_archive {
  my ($self, $archive) = @_;
  die "No such archive: $archive" if!-e $archive;
  my $ae = Archive::Extract->new(archive => $archive);
  $ae->extract(to => $self->environment_directory) or die $ae->error;
}

sub insert_hardlink {
  my ($self, $src) = @_;
  
  if (!ref $src) {
    $src = Path::Class::File->new($src);
  }

  # castaway's perl setup is a bit... odd.
  # PATH points to /home/castaway/perl5/perlbrew/bin/perl
  #  -> /home/castaway/perl5/perlbrew/perls/current/bin/perl5.10.1
  #     which is an actual binary file.
  # HOWEVER:
  # /home/castaway/perl5/perlbrew/perls/current
  #  -> perl-5.10.1


  my $orig_src = $src;
  print "insert_hardlink($src)\n";
  # We want to keep ".." from showing up, but we don't want to get the "real" name of symlinks.
  $src =~ s![^/]+/\.\./!/!;
  print " ... manual fuckery -> $src\n" if $src ne $orig_src;
  $orig_src = $src;
  print " ... cleanup -> $src\n" if $src ne $orig_src;
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
      print "$src is a symlink to $to\n";
      if (!-e $to) {
        print "symlink $src is broken, leaving it broken!\n";
      } else {
        # print "$src -> $to\n";
        $self->insert_hardlink($to);
      }
    }
    
    if (!-l $src) {
      # For a few filename patterns, we can assume they are what they appear to be.
      # The consequences of getting this wrong are minimal.
      my $magic;
      if ($src =~ m/\.(?:ix|al|pm)$/) {
        $magic = 'Perl5 module source text';
      } elsif ($src =~ m/\.so$/) {
        $magic = 'ELF 32-bit LSB shared object, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.18, stripped';
      } else {
        # warn "Getting magic for $src";
        
        $magic = `file $src`;
        chomp $magic;
      }

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
