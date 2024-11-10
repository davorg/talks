use strict;
use warnings;

use Feature::Compat::Class;
use feature 'signatures';
no warnings 'experimental::signatures';

class Talks {
  use Path::Tiny;
  use Template;
  use JSON;
  use Web::Sitemap;

  use Talks::Schema;

  field $json = JSON->new;
  field $config = _init_config($json);
  field $static_path = $config->{static_path} // 'static';
  field $output_path = $config->{output_path} // 'docs';
  field $ttlib_path  = $config->{ttlib_path}  // 'ttlib';
  field $tt_config = $config->{tt_config} // {
    INCLUDE_PATH => [ $ttlib_path ],
    OUTPUT_PATH => $output_path,
  };
  field $domain = $config->{domain} // '';

  field $tt = Template->new($tt_config);

  field $schema = Talks::Schema->connect('dbi:SQLite:dbname=db/talks.db');

  field @urls;

  sub _init_config($json) {
    if (-e 'talks.json') {
      return $json->decode(path('talks.json')->slurp_utf8);
    }
    return {};
  }

  method run() {
    $self->build;
  }

  method build() {
    $self->copy_static;
    $self->build_index;
    $self->build_years;
    $self->build_events;
    $self->build_types;
    $self->build_talks;
    $self->build_sitemap;
  }

  method copy_static(){
    my @files = grep { $_->is_file } path($static_path)->children;

    for (@files) {
      $_->copy(s/^$static_path/$output_path/r);
      push @urls, $_->stringify =~ s/^$static_path//r;
    }
  }

  method build_index() {
    $tt->process('index.tt', {}, 'index.html')
      or die $tt->error;
    push @urls, '/';
  }

  method build_years() {
    my $years = $schema->resultset('Year');
    $tt->process('year.tt', { years => [ $years->active ] }, 'year/index.html')
      or die $tt->error;
    push @urls, '/year/';
  }

  method build_events {
    my $series = $schema->resultset('EventSeries');
    $tt->process('events.tt', { series => [ $series->all ] }, 'event/index.html')
      or die $tt->error;
    push @urls, '/event/';

    my $events = $schema->resultset('Event');
    for my $event ($events->all) {
      my $file = 'event/' . $event->slug . '/index.html';
      $tt->process('event.tt', { event => $event }, $file)
        or die $tt->error;
      push @urls, '/event/' . $event->slug . '/';
    }
  }

  method build_types() {
    my $types = $schema->resultset('TalkType');
    $tt->process('types.tt', { types => [ $types->all ] }, 'type/index.html')
      or die $tt->error;
    push @urls, '/type/';
    for my $type ($types->all) {
      my $file = 'type/' . $type->slug . '/index.html';
      $tt->process('type.tt', { type => $type }, $file)
        or die $tt->error;
      push @urls, '/type/' . $type->slug . '/';
    }
  }

  method build_talks() {
    my $talks = $schema->resultset('Talk');
    $tt->process('talks.tt', { talks => [ $talks->sorted->all ] }, 'talk/index.html')
      or die $tt->error;
    push @urls, '/talk/';
    for my $talk ($talks->all) {
      my $file = 'talk/' . $talk->slug . '/index.html';
      $tt->process('talk.tt', { talk => $talk }, $file)
        or die $tt->error;
      push @urls, '/talk/' . $talk->slug . '/';
    }
  }

  method build_sitemap {
    my $sm_builder = Web::Sitemap->new(
      ($domain ? (loc_prefix => $domain) : ()),
      output_dir => $output_path,
    );
    $sm_builder->add([ grep { m[/$] } @urls ]);
    $sm_builder->finish;
  }
}
