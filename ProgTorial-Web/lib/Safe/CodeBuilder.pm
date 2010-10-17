# -*- mode: cperl -*-
package Safe::CodeBuilder;
use Moose;
use MooseX::StrictConstructor;
use Module::CoreList;
use Archive::Extract;
use File::Copy();
use JSON::Any;

has 'username',         is => 'ro';
has 'project',          is => 'ro';
has 'projects_dir',     is => 'ro';
has 'environments_dir', is => 'ro';
has 'debug',            is => 'rw', default => 0;

# Limits.
# Maximum memory that the subprocesses may use, in bytes.  (Note that the actual limit will be rounded down to the nearest 1024-byte increment.)
has 'max_memory',     is => 'rw', default => 20*1024*1024;
# Maximum amount of disk space that the entire environment can use, in bytes.  (Note that the actual limit will be rounded down to the nearest 1024-byte increment.)
has 'max_disk_space', is => 'rw', default => 100_000;

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
  return 1 if(-d $dest);
  $dest->mkpath;
  
  for my $thingy ('/dev/null',
                  '/dev/urandom',
                  (map {which($_)} qw<perl bash echo ls cat test [ sh which chmod chown touch true false cp make mv rm>),
                  $self->pm_file('Config')->parent->file('Config_heavy.pl'),
                  $self->pm_file('Config')->parent->file('Config_git.pl'),
                  # The core header files, required by MakeMaker even for non-XS modules.
                  $self->pm_file('Config')->parent->subdir('CORE'),
                  # Required for running tests.
                  $self->pm_file('JSON::Any'),
                  $self->pm_file('JSON::XS'),
                  $self->pm_file('common::sense'),
                  $self->pm_file('TAP::Parser')->parent,
                  $self->pm_file('TAP::Parser'),
                  #$self->pm_file('TAP::Parser::SourceHandler::Executable')->parent->parent->parent,
                  #$self->pm_file('TAP::Parser::SourceHandler::Executable'),
                  #$self->pm_file('TAP::Parser::SourceHandler'),
                  #$self->pm_file('TAP::Parser::SourceHandler::Perl'),
                  #$self->pm_file('TAP::Parser::SourceHandler::File'),
                  #$self->pm_file('TAP::Parser::SourceHandler::RawTAP'),
                  #$self->pm_file('TAP::Parser::SourceHandler::Handle'),
                  $self->pm_file('B::Utils'),
                  $self->pm_file('Data::Dump::Streamer'),
                  $self->pm_file('Data::Dump::Streamer')->parent->subdir('Streamer'),
                  
                  (map {$self->pm_file($_)}
                   grep {!($_ ~~ ['Time::Piece::Seconds', 'XS::APItest', 'DCLsym', 'Unicode', 'CGI::Fast', qr/Win32/])}
                   sort keys %{$Module::CoreList::version{$]}}
                  )) {
    #      print "Trying to link: $thingy\n";
    $self->insert_hardlink($thingy);
  }

  ## Our files needed to run the tests etc:
  $self->insert_actual_file($INC[-2],
                            $self->pm_file('Safe::TAPFormatter'), 
                            $self->class_to_file('Safe::TAPFormatter') );

  ## Extract project tarball
  $self->extract_archive($self->projects_dir->file($self->project.'-0.01.tar.gz'));
  
  my $chown = 'chmod -R 777 ' . $self->environment_directory->subdir($self->project.'-0.01');
  `$chown`;
}

sub run_in_child {
  my ($self, @command) = @_;

  my $envdir = $self->environment_directory;

  my $perl_dir = Path::Class::File->new(which('perl'))->dir;
  unshift @command, "export LANG=C";
  unshift @command, "export PATH=$perl_dir:/usr/bin:/bin";


  # -f: the maximum size of files written by the shell and its children
  # It is unclear (to us, anyway) if this is the size of the largest single file, or the
  # total size of the disk taken by all files written to by this process.

  # -m: the maximum resident set size
  #unshift @command, "ulimit -H -f ".$self->max_disk_space;
  #unshift @command, "ulimit -H -m ".$self->max_memory;


  my $cmd = join ';', @command;
  print STDERR "Running $cmd\n";
  local $ENV{LANG} = 'C';

  my $full_cmd = qq<sudo chroot --userspec 10005:10012 "$envdir" sh -c '$cmd'>;
  print STDERR "running $full_cmd\n";
  $| = 1;
  my $ret =`$full_cmd 2>&1`;
  {
    my $debug_ret = $ret;
    $debug_ret =~ s/^/child: /mg;
    print STDERR $debug_ret;
  }
  return $ret;
}

sub compile_project {
  my ($self) = @_;
  
#  my $dir_inside = '/'.$self->project.'-0.01/';
  my $dir_inside = $self->user_dir;
  $self->run_in_child("cd /$dir_inside; perl Makefile.PL");
  $self->run_in_child("cd /$dir_inside; make");
}

sub user_dir {
    my ($self) = @_;

    return $self->project.'-0.01/';
}

sub update_or_add_file {
    my ($self, $filedata) = @_;

    return if(!$filedata->{filename} || !$filedata->{content});

    ## Not writing a file this large, should this die (kill the process !?)
    if(length($filedata->{content}) > $self->max_disk_space) {
        die "File content (in update_or_add) too large for allowed disk space";
    }

    if($filedata->{filename} =~ /[^\w\/\.-]/ or
       $filedata->{filename} =~ m/^\./
      ) {
        die "Being picky about filename (in update_or_add) $filedata->{filename}";
        return;
    }

    my $newfile = $self->environment_directory->subdir($self->user_dir)->file($filedata->{filename});

    if (!$self->environment_directory->subsumes($newfile)) {
        die "$newfile is not within ".$self->environment_directory." (from $filedata->{filename})";
    }

    ## croaks if there is an error:
    $newfile->parent->mkpath();
    $newfile->touch();

    warn "Writing $filedata->{content} file to $newfile\n";
    my $fh = $newfile->openw();
    print $fh $filedata->{content} or die "Can't print to $newfile: $!";
    $fh->close or die "Can't close $newfile: $!";

    return 1;
}

## Copy the given file (find using path, copy using basename)
## into the given directory in the user environment
sub insert_actual_file {
    my ($self, $dir, $filefrom, $fileto) = @_;

    if(!-e $filefrom) {
        die "Can't insert_actual_file $filefrom, not found";
    }

    # warn "insert_actual_file, dir=$dir, filefrom=$filefrom, fileto=$fileto";
    my $dest = $self->environment_directory->subdir($dir)->file($fileto);
    if(!$self->environment_directory->subsumes($dest)) {
        die "Attempt to install file outside environment! $dir, $filefrom";
    }
    # die "Copying to $dest";

    $dest->parent->mkpath;
    File::Copy::copy("$filefrom", "$dest") or die "Copying $filefrom to $dest failed: $!";

    return 1;
}

sub run_test {
  my ($self, @testnames) = @_;
  
  open my $outfh, ">", $self->environment_directory
    ->subdir($self->project.'-0.01')
      ->file('runtests.pl');
  print $outfh <<'END_RUNTESTS';
#!/usr/bin/perl
#line 98 CodeBuilder.pm
use warnings;
use strict;
use Safe::TAPFormatter;
use TAP::Harness;
use TAP::Parser;
use JSON::Any;
#use Data::Dump::Streamer 'Dump', 'Dumper';

my @tests;
if (@ARGV) {
  @tests = @ARGV;
} else {
  @tests = glob('t/*.t');
}

## For debugging missing compiled libs
# $ENV{PERL_DL_DEBUG} = 1;

## Remove the output file before running tests, so bailing doesn't use the old one
if (-e "tests.json") {
  unlink "tests.json" or die("Can't remove tests.json $!");
}

my $formatter = Safe::TAPFormatter->new;

my $harness = TAP::Harness->new({
                                 lib  => [ 'blib/lib', 'blib/arch' ],
                                 formatter => $formatter
                                });
eval {
  my $aggregator = $harness->runtests(@tests);
};
if($@) {
  warn "Runtests died";
}
# Docs for JSON::XS are terribly unclear.
# allow_blessed   convert_blessed   effect
#             0                 0   encountered object 'TAP::Parser::Aggregator=HASH(0x834cd58)', but neither allow_blessed nor convert_blessed settings are enabled
#             0                 1   encountered object 'TAP::Parser::Aggregator=HASH(0x834cd88)', but neither allow_blessed enabled nor TO_JSON method available
#             1                 0   null
#             1                 1   null


#  
my $jsonifier = JSON::Any->new(allow_blessed => 0,
                               convert_blessed => 1,
                               allow_nonref => 1);


my $outfh;

#my $dds = Dumper($formatter);
#open $outfh, ">", 'tests.dds' or die "Couldn't open tests.dds: $!";
#print $outfh $dds or die "Can't print to dds file: $!";
#close $outfh or die "Can't close tests.dds: $!";

my $json = $jsonifier->objToJson($formatter);
open $outfh, ">", 'tests.json' or die "Couldn't open tests.json: $!";
print $outfh $json or die("Can't print to json file $!");
close $outfh or die("Can't close fh, $!");

END_RUNTESTS
  
  $self->run_in_child('cd '.$self->project.'-0.01; perl -Ilib runtests.pl '.join(' ', @testnames));
  
  my $json = do {local(@ARGV, $/) = $self->environment_directory->subdir($self->project.'-0.01')->file('tests.json'); <>};
  JSON::Any->jsonToObj($json);
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
#  print "insert_hardlink($src)\n";
  # We want to keep ".." from showing up, but we don't want to get the "real" name of symlinks.
  $src =~ s![^/]+/\.\./!/!;
  #print " ... manual fuckery -> $src\n" if $src ne $orig_src;
  $orig_src = $src;
  #print " ... cleanup -> $src\n" if $src ne $orig_src;
  $src = Path::Class::File->new($src)->cleanup;
  
  my $dest = Path::Class::File->new($self->environment_directory, "$src");
#  print "$src -> $dest\n";
  
  $dest->parent->mkpath;
  
  if (!-e "$src") {
    die "$src doesn't exist!";
  } elsif (-d "$src") {
    $src = Path::Class::Dir->new($src);
    Path::Class::Dir->new($dest)->mkpath;
    $self->insert_hardlink($_) for sort $src->children;
  } elsif(-e $dest) {
    ## Don't bother if we already have this, but do AFTER recursion
    ## cos the directory might partly exist already
    return;
  } elsif (-c $src) {
    my @args = ('sudo',
                'mknod',
                '--mode' => sprintf("0%o", 0777 & $src->stat->mode),
                $dest,
                'c',
                # This math is linux-specific
                $src->stat->rdev >> 8,
                $src->stat->rdev & 0xFF);
    print STDERR join(" ", @args), "\n";
    system @args;
  } elsif (-f $src) {
    
    #print "$src magic: $magic\n";
    if (-l $src) {
      my $to = Path::Class::File->new(readlink($src));
      if ($to->is_relative) {
        $to = Path::Class::File->new($src->parent, readlink($src));
      }
      print STDERR "$src is a symlink to $to\n";
      if (!-e $to) {
        print STDERR "symlink $src is broken, leaving it broken!\n";
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
      } elsif ($src =~ m{\.packlist}) {
        $magic = 'ASCII text';
      } elsif ($src =~ m/\.so$/) {
        $magic = 'ELF 32-bit LSB shared object, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.18, stripped';
      } elsif ($src =~ m/\.h$/) {
        $magic = 'ASCII C program text';
      } else {
#        warn "Getting magic for $src";
        
        $magic = `file $src`;
        chomp $magic;
      }

      if ($magic =~ m/dynamically linked/) {
        my $ldd = `ldd $src`;
        for my $line (split /\n/, $ldd) {
          if ($line =~ m/statically linked/) {
            next;
          } elsif ($line =~ m/ => (.+) \(0x/) {
            # '	libnsl.so.1 => /lib/libnsl.so.1 (0xb7828000)'
            $self->insert_hardlink($1);
          } elsif ($line =~ m!^\s*(/.+) \(0x!) {
            $self->insert_hardlink($1);
          } elsif ($line =~ m! =>  \(0x!) {
            # linux-gate.so.1 =>  (0xb785c000)
            # http://www.trilithium.com/johan/2005/08/linux-gate/
            # The empty bit after the => is because ldd can't find the file.  That's OK, because it's not actually supposed to exist.
            next;
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

# NB: You can call Path::Class methods on the result, but it will give
# poor error messages if it fails.
sub pm_file {
  my ($self, $classname) = @_;
  # $self is unused.

  $classname = $self->class_to_file($classname);

  for (@INC) {
    my $filename = "$_/$classname";
    if (-e $filename) {
      # Used by autosplit and XS modules.
      my $autoname = "$_/auto/$classname";
      $autoname =~ s/\.pm$//;
      if (-e $autoname and wantarray) {
        return ($filename, $autoname);
      }
      return Path::Class::File->new($filename);
    }
  }

  warn "Can't find $classname";
  return ();
}

sub class_to_file {
    my ($self, $classname) = @_;

    if ($classname !~ m/\.pl$/) {
        $classname =~ s!::!/!g;
        $classname .= ".pm";
    }
    
    return $classname;
}

# sub, not method
sub which {
  my $x = shift;
  my $foo = `which $x`;
  chomp $foo;
  return $foo;
}


1;
