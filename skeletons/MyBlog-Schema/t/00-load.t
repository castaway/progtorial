#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'MyBlog::Schema' ) || print "Bail out!
";
}

diag( "Testing MyBlog::Schema $MyBlog::Schema::VERSION, Perl $], $^X" );
