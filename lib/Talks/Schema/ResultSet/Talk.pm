package Talks::Schema::ResultSet::Talk;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub sorted {
  my $self = shift;

  return $self->search(undef, {
    order_by => { -asc => 'title' },
  });
}

1;
