use strict;
use warnings;

use Feature::Compat::Class;
use feature 'signatures';
no warnings 'experimental::signatures';

use Template;
use JSON;
use Path::Tiny;

use Talks::Schema;

class Talks {
  field $json = JSON->new;
  field $config = _init_config($json);
  field $tt_config = $config->{tt_config} // {
    INCLUDE_PATH => [ 'src', 'ttlib'],
    OUTPUT_PATH => 'docs',
  };

  field $tt = Template->new($tt_config);

  field $schema = Talks::Schema->connect('dbi:SQLite:dbname=db/talks.db');

  sub _init_config($json) {
    if (-e 'talks.json') {
      return $json->decode(path('config.json')->slurp_utf8);
    }
    return {};
  }

  method run() {
    $self->build;
  }

  method build() {
    $self->build_index;
    $self->build_years;
    $self->build_events;
    $self->build_types;
    $self->build_talks;
  }

  method build_index() {
    $tt->process('index.tt', {}, 'index.html')
      or die $tt->error;
  }

  method build_years() {
    my $years = $schema->resultset('Year');
    $tt->process('year.tt', { years => [ $years->active ] }, 'year/index.html')
      or die $tt->error;
  }

  method build_events {
    my $series = $schema->resultset('EventSeries');
    $tt->process('events.tt', { series => [ $series->all ] }, 'event/index.html')
      or die $tt->error;

    my $events = $schema->resultset('Event');
    for my $event ($events->all) {
      my $file = 'event/' . $event->slug . '/index.html';
      $tt->process('event.tt', { event => $event }, $file)
        or die $tt->error;
    }
  }

  method build_types() {
    my $types = $schema->resultset('TalkType');
    $tt->process('types.tt', { types => [ $types->all ] }, 'type/index.html')
      or die $tt->error;
  }

  method build_talks() {
    my $talks = $schema->resultset('Talk');
    $tt->process('talks.tt', { talks => [ $talks->sorted->all ] }, 'talk/index.html')
      or die $tt->error;
    for my $talk ($talks->all) {
      my $file = 'talk/' . $talk->slug . '/index.html';
      $tt->process('talk.tt', { talk => $talk }, $file)
        or die $tt->error;
    }
  }
}
