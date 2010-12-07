#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 23;

## Testing functions which should be in lib/add_function.pl

do 'lib/add_function.pl';
ok(main->can('add'), 'Found function called "add"');

is(add(2,5), 7, '2 + 5 = 7');
is(add(1, 3, -1), 3, '1+3+-1 (coped with more than two args)');
for (1..20) {
    my $x = rand();
    my $y = rand()*20 - rand*10;
    my $sum = $x + $y;

    is(add($x, $y), $sum, "$x + $y = $sum (randomly chosen)");
}

done_testing;
