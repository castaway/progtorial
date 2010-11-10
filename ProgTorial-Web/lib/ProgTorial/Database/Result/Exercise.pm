package ProgTorial::Database::Result::Exercise;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('exercises');
__PACKAGE__->add_columns(
                         exercise => {
                                      data_type => 'varchar',
                                      size => '50',
                                      },
                         tutorial => {
                                      data_type => 'varchar',
                                      size => 50,
                                     },
                         );
__PACKAGE__->set_primary_key('exercise', 'tutorial');
__PACKAGE__->belongs_to('tutorial', 'ProgTorial::Database::Result::Tutorial');

'done coding';
