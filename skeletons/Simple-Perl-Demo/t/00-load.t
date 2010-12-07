#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

do 'lib/add_function.pl';

ok(main->can('add_function'), 'Found function called "add"');
