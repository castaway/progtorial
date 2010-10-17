#!/usr/bin/perl

## Initial ideas for code building/testing backend, expressed as tests
## I think this will end up as a Model in the app
## It will be constructed/updated for each accept_context (request) that requires code to be tested
## against the tutorial tests.

## Each user has a code area (chroot) which will default to a skeleton distribution
## (does it compile on its own? probably should) which the user can add to by doing the tutorial
## exercises. Each exercise will be checked by running the dist-to-date against perl tests. 

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Path::Class;
use Data::Dumper;

Path::Class::Dir->new('t/environments/fred')->rmtree;

## Probably needs a better name
use_ok('Safe::CodeBuilder');

my $cb = Safe::CodeBuilder->new({
                                 ## users own (chroot) environment named after this, so should be a valid path name?
                                 username => 'fred',
                                 ## project/dist to extract/build
                                 ## tarball is t/projects/MyBlog-Schema.tar.gz
                                 project => 'MyBlog-Schema',
                                 projects_dir => Path::Class::Dir->new('t/projects'),
                                 environments_dir => Path::Class::Dir->new('t/environments'),
                                });

isa_ok($cb, 'Safe::CodeBuilder');

## eg, t/environments/fred/MyBlog-Schema
ok(!-d $cb->environment_directory, 'Initially, no coding environment exists');

## create chroot env and unpack MyBlog-Schema.tar.gz (is it versioned?)
lives_ok(sub { $cb->create_environment_directory() }, 'Created code directory without failing');

ok(-d $cb->environment_directory, 'Created coding environment');
## Assumes debian ish 5.10 env
# ok(-e $cb->environment_directory->file('usr/share/perl/5.10/strict.pm'), 'Copied strict.pm');

## Update env with deps:
## (better handling of deps for project X needed)
for (grep {$_ =~ /perlbrew/ && -e} @INC) {
    print STDERR "Adding INC $_\n";
    $cb->insert_hardlink($_);
}

ok(-e $cb->environment_directory->file('MyBlog-Schema-0.01/Makefile.PL'), 'Unpacked tarball there');

## Make/Test compiled with empty enc, should pass:
ok(!-e $cb->environment_directory->file('MyBlog-Schema-0.01/Makefile'), 'Project makefile doesn\'t exist yet');
ok($cb->compile_project(), 'Compiled project without errors');
ok(-e $cb->environment_directory->file('MyBlog-Schema-0.01/Makefile'), 'Project makefile exists after compiling');
ok(-e $cb->environment_directory->file('MyBlog-Schema-0.01/blib/lib/MyBlog/Schema.pm'), '.pm file copied to blib after compiling');

my $loadtest = $cb->run_test('t/00-load.t');
print Dumper($loadtest);
ok($loadtest->{all_ok}, 'PASSED load test');

## Update/add code from user input:
ok($cb->update_or_add_file({
    filename => 'lib/MyBlog/Schema/Result/Post.pm',
    content => << 'POSTPM',
package MyBlog-Schema::Schema::Result::Post;

use strict;
use warnings

use base 'DBIx::Class::Core';

__PACKAGE__->table('posts');
__PACKAGE__->add_columns('id' => { data_type => 'integer', is_auto_increment => 1 }, 'title', 'post', 'postdate');
__PACKAGE__->set_primary_key('id');

1;
POSTPM
                           }), 'Added new file Post.pm to project');

ok(-e $cb->environment_directory->file('MyBlog-Schema-0.01/lib/MyBlog/Schema/Result/Post.pm'), 'New Post.pm file exists');
ok($cb->compile_project(), 'Project still compiles');

$loadtest = $cb->run_test('t/00-load.t', 't/create-post-class.t');
print Dumper($loadtest);
ok($loadtest->{all_ok}, 'PASSED Post tests');



## Add broken file:
ok($cb->update_or_add_file({
    filename => 'lib/MyBlog/Schema/Result/Test.pm',
    content => << 'TESTPM',
package MyBlog-Schema::Schema::Result::Test;

use strict;
use warnings

use base 'DBIx::Class::Core';

## Bug on line 9:
__PACKAGE__->table('testing'
__PACKAGE__->add_columns('id' => { data_type => 'integer', is_auto_increment => 1 }, 'title', 'post', 'postdate');
__PACKAGE__->set_primary_key('id');

1;

TESTPM
                           }), 'Added new file Test.pm to project');

ok(!$cb->compile_project(), 'Project doesn\'t compile (errors in code)');
## The actual error text here needs fixing:
#is_deeply([$cb->errors], ['MyBlog-Schema-0.01/lib/MyBlog/Schema/Result/Test.pm: Error on line 9'], 'Found errors');

## at some point we need to repack the users work into a tarball so we can remove the env if needed..
#$cb->tidyup;


done_testing;
