package ProgTorial::Database::Result::Solution;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components('Ordered');
__PACKAGE__->table('solutions');
__PACKAGE__->add_columns(
                         user_id => {
                                     data_type => 'integer',
                                     },
                         tutorial => {
                                      data_type => 'varchar',
                                      size => 50,
                                      },
                         exercise => {
                                      data_type => 'varchar',
                                      size => 50,
                                      is_nullable => 1,
                                     },
                         ## Grouped for each exercise
                         attempt => {
                             data_type => 'integer',
                         },
                         results => {
                             data_type => 'varchar',
                             size => 2048,
                         },
                         );
__PACKAGE__->set_primary_key('user_id', 'tutorial', 'exercise', 'attempt');
__PACKAGE__->position_column('attempt');
__PACKAGE__->grouping_column(['tutorial', 'exercise']);
__PACKAGE__->belongs_to('user', 'ProgTorial::Database::Result::User', 'user_id');
__PACKAGE__->belongs_to('tutorial', 'ProgTorial::Database::Result::Tutorial', 'tutorial');
__PACKAGE__->belongs_to('exercise', 'ProgTorial::Database::Result::Exercise', { 'foreign.exercise' => 'self.exercise', 'foreign.tutorial' => 'self.exercise'});
'done coding';
