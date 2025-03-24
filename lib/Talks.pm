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
    push @urls, '/';
    $tt->process('index.tt', {
      canonical => $urls[-1],
    }, 'index.html')
      or die $tt->error;
  }

  method build_years() {
    push @urls, '/year/';
    my $years = $schema->resultset('Year');
    $tt->process('year.tt', {
      years => [ $years->active ],
      canonical => $urls[-1],
    }, 'year/index.html')
      or die $tt->error;
  }

  method build_events {
    push @urls, '/event/';
    my $series = $schema->resultset('EventSeries');
    $tt->process('events.tt', {
      series => [ $series->all ],
      canonical => $urls[-1],
    }, 'event/index.html')
      or die $tt->error;

    my $events = $schema->resultset('Event');
    for my $event ($events->all) {
      push @urls, '/event/' . $event->slug . '/';
      my $file = 'event/' . $event->slug . '/index.html';
      $tt->process('event.tt', {
        event => $event,
        canonical => $urls[-1],
      }, $file)
        or die $tt->error;
    }
  }

  method build_types() {
    my $types = $schema->resultset('TalkType');
    push @urls, '/type/';
    $tt->process('types.tt', {
      types => [ $types->all ],
      canonical => $urls[-1],
    }, 'type/index.html')
      or die $tt->error;
    for my $type ($types->all) {
      push @urls, '/type/' . $type->slug . '/';
      my $file = 'type/' . $type->slug . '/index.html';
      $tt->process('type.tt', {
        type => $type,
        canonical => $urls[-1],
      }, $file)
        or die $tt->error;
    }
  }

  method build_talks() {
    push @urls, '/talk/';
    my $talks = $schema->resultset('Talk');
    $tt->process('talks.tt', {
      talks => [ $talks->sorted->all ],
      canonical => $urls[-1],
    }, 'talk/index.html')
      or die $tt->error;
    for my $talk ($talks->all) {
      push @urls, '/talk/' . $talk->slug . '/';
      my $file = 'talk/' . $talk->slug . '/index.html';
      $tt->process('talk.tt', {
        talk => $talk,
        canonical => $urls[-1],
      }, $file)
        or die $tt->error;
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

1;
