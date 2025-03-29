package Talks::Schema::ResultSet::Presentation;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub most_recent_presentations {
  my $self = shift;
  my ($count) = @_;
  $count ||= 3;

  my $subquery = $self->search(
    {},
    {
      select   => ['talk_id', { max => 'datetime' }],
      as       => ['talk_id', 'latest_datetime'],
      group_by => ['talk_id'],
    }
  );

  my $rs = $self->search(
    {
      'me.talk_id'  => { -in => $subquery->get_column('talk_id')->as_query },
      'me.datetime' => { -in => $subquery->get_column('latest_datetime')->as_query },
    },
    {
      join     => ['talk'],
      prefetch => 'talk',
      order_by => { -desc => 'me.datetime' },
      rows     => $count,
    }
  );

  return $rs->all;
}

1;
