use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use File::Copy qw(copy);
use File::Temp qw(tempdir);
use Template;
use Test::More;
use Talks::IndexPage;
use Talks::Schema;

my $root = "$FindBin::Bin/..";
my $tmp = tempdir(CLEANUP => 1);
copy("$root/db/talks.db", "$tmp/archive.db") or die "Copy database: $!";
my $schema = Talks::Schema->connect("dbi:SQLite:dbname=$tmp/archive.db");
$schema->txn_do(sub {
  $schema->resultset($_)->delete for qw(BackfillSource TalkLink Presentation Event Talk);
});

is_deeply($schema->archive_statistics, { presentations => 0, talks => 0, years => 0 },
  'empty archive ignores seeded years');

my $unused = $schema->resultset('Talk')->create({ title => 'Not yet presented', talk_type_id => 2 });
is_deeply($schema->archive_statistics, { presentations => 0, talks => 0, years => 0 },
  'talks without presentations do not inflate the subtitle');

sub event_in {
  my ($year) = @_;
  my $row = $schema->resultset('Year')->find_or_create({ year => $year });
  return $schema->resultset('Event')->create({
    name => "Statistics test $year", start_date => "$year-01-01",
    year_id => $row->id, event_series_id => 1, is_online => 1,
  });
}

my $earliest = event_in(2000);
my $latest = event_in(2026);
event_in(2100); # An event with no presentations must not extend the span.
my $talk = $schema->resultset('Talk')->create({ title => 'Repeated talk', talk_type_id => 2 });
my $first = $talk->create_related('presentations', { event_id => $earliest->id });
is_deeply($schema->archive_statistics, { presentations => 1, talks => 1, years => 1 },
  'one presentation counts even without an exact datetime');

$talk->create_related('presentations', {
  event_id => $latest->id, datetime => '2026-01-01 10:00:00',
});
is_deeply($schema->archive_statistics, { presentations => 2, talks => 1, years => 26 },
  'repeat deliveries count separately; event years include an uncertain earliest date');

$unused->create_related('presentations', { event_id => $latest->id });
is_deeply($schema->archive_statistics, { presentations => 3, talks => 2, years => 26 },
  'fresh queries reflect a new presentation and a newly presented talk');

my $tt = Template->new({ INCLUDE_PATH => "$root/ttlib" });
my $index = Talks::IndexPage->new(
  title => 'Talks by Dave Cross', description => 'Talk archive', url_path => '/',
);
sub header_html {
  my $html;
  $tt->process('index.tt', {
    object => $index, archive_stats => $schema->archive_statistics,
    recent_presentations => [], recent_additions => [],
  }, \$html) or die $tt->error;
  return $html;
}
like(header_html(), qr{class="site-subtitle">3 presentations of 2 talks over 26 years</p>},
  'shared header renders the current totals');

$first->delete;
is($schema->archive_statistics->{years}, 1, 'removing the earliest delivery updates the year span');
$schema->resultset('Presentation')->delete;
$talk->create_related('presentations', { event_id => $latest->id });
like(header_html(), qr{class="site-subtitle">1 presentation of 1 talk over 1 year</p>},
  'subtitle uses singular nouns for one');

done_testing;
