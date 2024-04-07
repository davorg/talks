package Talks::Schema::ResultSet::Year;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub active {
  my $self = shift;

  return sort { $a->year <=> $b->year }
    grep { $_->events->count } $self->all;
}

1;
