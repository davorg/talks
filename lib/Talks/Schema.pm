use utf8;
package Talks::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-01-25 20:33:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9ZCNqCJs5EaEwmTHbse7Jg

sub get_schema {
  die "Please set TALKS_DB_FILE\n"           unless $ENV{TALKS_DB_FILE};
  die "$ENV{TALKS_DB_FILE} does not exist\n" unless -e $ENV{TALKS_DB_FILE};
  die "Can't read $ENV{TALKS_DB_FILE}\n"     unless -r $ENV{TALKS_DB_FILE};

  return __PACKAGE__->connect('dbi:SQLite:dbname=db/talks.db');
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
