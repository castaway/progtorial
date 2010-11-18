package ProgTorial::Database::Result::Setting;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('settings');
__PACKAGE__->add_columns(
    id => {
        data_type => 'integer',
    },
    name => {
        data_type => 'varchar',
        size => 50,
    });

__PACKAGE__->set_primary_key('id');

'done coding';

