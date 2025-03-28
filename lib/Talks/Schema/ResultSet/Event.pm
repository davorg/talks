package Talks::Schema::ResultSet::Event;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub sorted {
  my $self = shift;

  return $self->search(undef, {
    order_by => { -asc => 'start_date' },
  });
}

1;
