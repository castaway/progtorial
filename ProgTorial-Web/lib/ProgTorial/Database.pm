package ProgTorial::Database;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

our $VERSION = "2.0";

__PACKAGE__->load_namespaces(
    default_resultset_class => 'RSBase',
   );

1;
