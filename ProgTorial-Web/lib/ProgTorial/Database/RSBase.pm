package ProgTorial::Database::RSBase;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

__PACKAGE__->load_components('Helper::ResultSet::SetOperations');

'done coding';
