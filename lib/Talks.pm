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
    my $talks = $schema->resultset('Talk');
    for my $talk ($talks->all) {
      my $file = $talk->slug . '.html';
      $tt->process('talk.tt', { talk => $talk }, $file)
        or die $tt->error;
    }
  }
}