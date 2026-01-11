package Talks::Schema::ResultSet::Talk;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub sorted {
  my $self = shift;

  return $self->search(undef, {
    order_by => { -asc => 'title' },
  });
}

sub recent_additions {
  my $self = shift;
  my ($limit) = @_;

  $limit //= 3;

  my @talks = $self->search(undef, {
    order_by => { -desc => 'id' },
  });

  if (@talks > $limit) {
    $#talks = $limit - 1;
  }

  return @talks;
}

1;
