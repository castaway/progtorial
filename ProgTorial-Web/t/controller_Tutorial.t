use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'ProgTorial::Web' }
BEGIN { use_ok 'ProgTorial::Web::Controller::Tutorial' }

ok( request('/tutorial')->is_success, 'Request should succeed' );
done_testing();
