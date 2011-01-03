package ProgTorial::Database::Result::OpenID;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('openids');
__PACKAGE__->add_columns(
    user_id => {
        data_type => 'integer',
        is_nullable => 1,
    },
    url => {
        data_type => 'varchar',
        size => 1024,
    }
    );

__PACKAGE__->set_primary_key('url');
__PACKAGE__->belongs_to('user', 'ProgTorial::Database::Result::User', 'user_id', { is_foreign_key_constraint => 0 });

'done coding';
