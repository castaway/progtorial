#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Data::Dump::Streamer 'Dumper';
use Path::Class;

use_ok('Safe::CodeBuilder');
my $cb = Safe::CodeBuilder->new({
                                 ## users own (chroot) environment named after this, so should be a valid path name?
                                 username => 'fred',
                                 ## project/dist to extract/build
                                 ## tarball is t/projects/MyBlog-Schema.tar.gz
                                 project => 'Safe-Test',
                                 projects_dir => Path::Class::Dir->new('t/projects'),
                                 environments_dir => Path::Class::Dir->new('t/environments'),
                                });

$cb->create_environment_directory();
## Assumes env is set up already

ok($cb->compile_project(), 'Compiled project without errors');
my $ret;
$ret = $cb->run_test('t/2ok.t');
ok(1, 'Survived an OK test');
diag(Dumper(['ok test', $ret]));
     
$ret = $cb->run_test('t/not_ok.t');
ok(1, 'Survived a FAIL test');
diag(Dumper(['not_ok test', $ret]));

$ret = $cb->run_test('t/bail.t');
ok(1, 'Survived a bail test');
diag(Dumper(['bail test', $ret]));



done_testing;
