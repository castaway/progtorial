use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'ProgTorial::Web' }
BEGIN { use_ok 'ProgTorial::Web::Controller::Chapter' }

# ok( request('/chapter')->is_success, 'Request should succeed' );
done_testing();
