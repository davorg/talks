package Talks::Schema::ResultSet::Year;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub active {
  my $self = shift;

  return grep { $_->events->count } $self->all;
}

1;
