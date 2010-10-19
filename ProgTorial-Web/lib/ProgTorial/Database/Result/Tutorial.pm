package ProgTorial::Database::Result::Tutorial;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('tutorials');
__PACKAGE__->add_columns(
                         # FIXME: rename this "name" ?
                         tutorial => {
                                      data_type => 'varchar',
                                      size => '50',
                                      },
                         );
__PACKAGE__->set_primary_key('tutorial');
__PACKAGE__->has_many('exercises', 'ProgTorial::Database::Result::Exercise', 'tutorial');

'done coding';
