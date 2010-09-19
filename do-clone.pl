#!/usr/bin/perl
use warnings;
use strict;
use Path::Class;
use Module::CoreList;
use 5.10.0;

sub make_chroot_env {
  my ($dest_dir) = @_;
  
  if (!ref $dest_dir) {
    $dest_dir = Path::Class::Dir->new($dest_dir);
  }

  $dest_dir->mkpath;

  my @todo = (which('perl'),
              '/bin/bash',
              '/bin/sh',
              '/usr/bin/make',
              '/dev/null',
              '/dev/urandom',
              '/usr/bin/strace',
              '/usr/lib/locale/locale-archive',
              # '/usr/share/locale/en_US.utf8',
#              '/usr/share/locale/en_US',
              # '/usr/share/locale/en.utf8',
              '/usr/share/locale/en',
              pm_file('Config')->parent->file('Config_heavy.pl'),
              pm_file('Config')->parent->file('Config_git.pl'),
              pm_file('DBD::SQLite'),
              pm_file('DBI'),
              pm_file('Class::Accessor::Grouped'),
              pm_file('Sub::Name'),
              pm_file('DBIx::Class'),
              pm_file('DBIx::Class')->parent->file('Class'),
              pm_file('MRO::Compat'),
              pm_file('Class::C3::Componentised'),
              pm_file('Class::C3'),
              pm_file('Class::Inspector'),
              pm_file('Carp::Clan'),
              which('sqlite3'),
             );
  push @todo, map {pm_file($_)}
    grep {!($_ ~~ ['Time::Piece::Seconds', 'XS::APItest', 'DCLsym', 'Unicode', 'CGI::Fast', qr/Win32/])}
      keys %{$Module::CoreList::version{$]}};
  my %done;
  while (@todo) {
    my $todo = shift @todo;
    # Phantom!
    next if !$todo;
    if (!ref $todo) {
      $todo = Path::Class::File->new($todo);
    }
    # We want to keep ".." from showing up, but we don't want to get the "real" name of symlinks.
    $todo =~ s![^/]+/\.\./!/!;
    $todo = Path::Class::File->new($todo)->cleanup;
    next if $done{$todo}++;

    my $dest = Path::Class::File->new("$dest_dir/$todo");
    # print "$todo -> $dest\n";

    $dest->parent->mkpath;

    if (!-e $todo) {
      die "$todo doesn't exist!";
    } elsif (-d $todo) {
      $todo = Path::Class::Dir->new($todo);
      Path::Class::Dir->new($dest)->mkpath;
      push @todo, $todo->children;
    } elsif (-c $todo) {
      my @args = ('mknod',
                  '--mode' => sprintf("0%o", 0777 & $todo->stat->mode),
                  $dest,
                  'c',
                  # This math is linux-specific
                  $todo->stat->rdev >> 8,
                  $todo->stat->rdev & 0xFF);
      print join(" ", @args), "\n";
      system @args;
    } elsif (-f $todo) {
      my $magic = `file $todo`;
      chomp $magic;
      # FIXME: Better way to express this?

      #print "$todo magic: $magic\n";
      if (-l $todo) {
        my $to = Path::Class::File->new($todo->parent, readlink($todo));
        if (!-e $to) {
          print "symlink $todo is broken, leaving it broken!\n";
        } else {
          # print "$todo -> $to\n";
          push @todo, $to;
        }
      } elsif ($magic =~ m/dynamically linked/) {
        my $ldd = `ldd $todo`;
        for my $line (split /\n/, $ldd) {
          if ($line =~ m/statically linked/) {
            next;
          } elsif ($line =~ m/ => (.*) \(0x/) {
            push @todo, $1;
          } elsif ($line =~ m!^\s*(/.*) \(0x!) {
            push @todo, $1;
          } else {
            die "Don't know what to do for ldd line '$line' from $todo";
          }
        }
      }
      
      link($todo, $dest) or die "Can't make link from $todo to $dest: $!";
    } else {
      die "$todo isn't a directory, char dev, or file";
    }
  }
}

sub pm_file {
  my ($classname) = @_;
  if ($classname !~ m/\.pl$/) {
    $classname =~ s!::!/!g;
    $classname .= ".pm";
  }

  for (@INC) {
    my $filename = "$_/$classname";
    if (-e $filename) {
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

sub which {
  my $x = shift;
  my $foo = `which $x`;
  chomp $foo;
  return $foo;
}

make_chroot_env('/tmp/chroot_here');
