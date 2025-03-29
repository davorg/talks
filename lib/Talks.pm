use v5.36;

use feature qw[signatures class];
no warnings 'experimental::class';

class Talks {
  use Path::Tiny;
  use Template;
  use JSON;
  use WWW::Sitemap::Simple;

  use Talks::IndexPage;
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
    my $index = Talks::IndexPage->new(
      url_path => '/',
      title => 'Talks by Dave Cross',
      description => 'A collection of talks by Dave Cross',
    );
    push @urls, $index->url_path;

    my @recent_presentations = $schema->resultset('Presentation')->most_recent_presentations();

    $tt->process('index.tt', {
      object => $index,
      recent_presentations => \@recent_presentations,
    }, $index->outfile)
      or die $tt->error;
  }

  method build_years() {
    my $index = Talks::IndexPage->new(
      url_path => '/year/',
      title => 'Talks by Dave Cross - by year',
      description => 'A collection of talks by Dave Cross',
    );
    push @urls, $index->url_path;
    my $years = $schema->resultset('Year');
    $tt->process('year.tt', {
      years => [ $years->active ],
      object => $index,
    }, $index->outfile)
      or die $tt->error;
  }

  method build_events {
    my $index = Talks::IndexPage->new(
      url_path => '/event/',
      title => 'Talks by Dave Cross - by event',
      description => 'A collection of talks by Dave Cross',
    );
    push @urls, $index->url_path;
    my $series = $schema->resultset('EventSeries');
    $tt->process('events.tt', {
      series => [ $series->all ],
      object => $index,
    }, $index->outfile)
      or die $tt->error;

    my $events = $schema->resultset('Event');
    for my $event ($events->all) {
      push @urls, $event->url_path;
      $tt->process('event.tt', {
        object => $event,
      }, $event->outfile)
        or die $tt->error;
    }
  }

  method build_types() {
    my $index = Talks::IndexPage->new(
      url_path => '/type/',
      title => 'Talks by Dave Cross - by type',
      description => 'A collection of talks by Dave Cross',
    );
    my $types = $schema->resultset('TalkType');
    push @urls, $index->url_path;
    $tt->process('types.tt', {
      types => [ $types->all ],
      object => $index
    }, $index->outfile)
      or die $tt->error;
    for my $type ($types->all) {
      push @urls, $type->url_path;
      $tt->process('type.tt', {
        object => $type,
      }, $type->outfile)
        or die $tt->error;
    }
  }

  method build_talks() {
    my $index = Talks::IndexPage->new(
      url_path => '/talk/',
      title => 'Talks by Dave Cross - by talk',
      description => 'A collection of talks by Dave Cross',
    );
    push @urls, $index->url_path;
    my $talks = $schema->resultset('Talk');
    $tt->process('talks.tt', {
      talks => [ $talks->sorted->all ],
      object => $index,
    }, $index->outfile)
      or die $tt->error;
    for my $talk ($talks->all) {
      push @urls, $talk->url_path;
      $tt->process('talk.tt', {
        object => $talk,
      }, $talk->outfile)
        or die $tt->error;
    }
  }

  method build_sitemap {
    my $sm_builder = WWW::Sitemap::Simple->new(indent => '  ');
    $sm_builder->add("$domain$_") for grep { m[/$] } @urls;
    $sm_builder->write("$output_path/sitemap.xml");
  }
}

1;
