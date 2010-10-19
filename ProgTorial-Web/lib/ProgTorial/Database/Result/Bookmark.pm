package ProgTorial::Database::Result::Bookmark;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('bookmarks');
__PACKAGE__->add_columns(
                         user_id => {
                                     data_type => 'integer',
                                     },
                         tutorial => {
                                      data_type => 'varchar',
                                      size => 50,
                                      },
                         chapter => {
                                     data_type => 'varchar',
                                     size => 50,
                                    },
                         exercise => {
                                      data_type => 'varchar',
                                      size => 50,
                                      is_nullable => 1,
                                     },
                         );
__PACKAGE__->set_primary_key('user_id', 'tutorial', 'exercise');
__PACKAGE__->belongs_to('user', 'ProgTorial::Database::Result::User', 'user_id');
__PACKAGE__->belongs_to('tutorial', 'ProgTorial::Database::Result::Tutorial', 'tutorial');
__PACKAGE__->belongs_to('exercise', 'ProgTorial::Database::Result::Exercise', 'exercise');

'done coding';
