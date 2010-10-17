#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
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
                                 ## Debugging, ON
                                 debug => 1,
                                 ## max size of memory code can use (bytes)
                                 max_memory => 20_000,
                                 ## Max diskspace entire env can use
                                 max_disk_space => 100_000,

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

dies_ok(sub { $cb->update_or_add_file({
    filename => 'BIGFILETEST.txt',
    content => ('a' x 100_000),
}) }, 'dies when asked to store file larger than allowed disk space');

# # I have no idea what this is attempting to test.
# $cb->update_or_add_file({
#                          filename => 'Makefile.PL',
#                          content => << 'BIGFILE',
# my @foo = ('a' x 20_000);
# BIGFILE
# });
# dies_ok(sub { $cb->compile_project() }, 'Died ok trying to compile oversize file');

done_testing(6);
