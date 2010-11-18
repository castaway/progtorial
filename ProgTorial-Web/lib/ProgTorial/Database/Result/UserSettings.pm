package ProgTorial::Database::Result::UserSettings;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('user_settings');
__PACKAGE__->add_columns(
    user_id => {
        data_type => 'integer',
    },
    setting_id => {
        data_type => 'integer',
    },
    value => {
        data_type => 'boolean',
    });

__PACKAGE__->set_primary_key('user_id', 'setting_id');
__PACKAGE__->belongs_to('user', 'ProgTorial::Database::Result::User', 'user_id');
__PACKAGE__->belongs_to('setting', 'ProgTorial::Database::Result::Setting', 'setting_id');

'done coding';

