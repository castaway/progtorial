package ProgTorial::Database::Result::Status;

use strict;
use warnings;

use base 'DBIx::Class::Core';

## This is a dummy source!
__PACKAGE__->table('dummy');
__PACKAGE__->add_columns(
                         user_id => {
                                     data_type => 'integer',
                                     },
                         occurred_on => {
                             data_type => 'datetime',
                             set_on_create => 1,
                         },
                         status => {
                             data_type => 'varchar',
                             size => 2048,
                         },
                         );
__PACKAGE__->set_primary_key('user_id', 'occurred_on', 'status');
__PACKAGE__->belongs_to('user', 'ProgTorial::Database::Result::User', 'user_id');

'done coding';
