use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use File::Copy qw(copy);
use File::Temp qw(tempdir);
use Template;
use Test::More;
use Talks::Schema;

my $tmp = tempdir(CLEANUP => 1);
copy("$FindBin::Bin/../db/talks.db", "$tmp/archive.db") or die $!;
my $schema = Talks::Schema->connect("dbi:SQLite:dbname=$tmp/archive.db");
my $first = $schema->resultset('Talk')->create({ title => 'Modern Perl', talk_type_id => 2 });
my $second = $schema->resultset('Talk')->create({
  title => 'Modern PERL', talk_type_id => 1, url_slug => 'modern-perl-render-test', has_image => 1,
});
is($first->title, 'Modern Perl', 'title case is preserved');
is($second->title, 'Modern PERL', 'the distinct uppercase title is preserved');
isnt($first->url_path, $second->url_path, 'case-distinct talks can have distinct stable URLs');
is($second->url_path, '/talk/modern-perl-render-test/', 'explicit URL slug is used');

my $event = $schema->resultset('Event')->create({
  name => 'Precision test', start_date => '2001-07-23', end_date => '2001-07-27',
  year_id => 2, event_series_id => 1, location_text => 'San Diego, USA',
});
is($event->location, 'San Diego, USA', 'known city is retained without fabricating a venue');
like($event->description, qr/San Diego, USA/, 'page metadata works without a named venue');

my $presentation = $second->create_related('presentations', {
  event_id => $event->id, date_label => 'July 2001 (exact day not recorded)',
  slide_url => 'https://example.com/slides?a=1&b=2',
  video_url => 'https://example.com/video',
});
ok(!defined $presentation->datetime, 'uncertain day has no invented timestamp');
is($presentation->display_datetime, 'July 2001 (exact day not recorded)', 'qualified date is displayed');
my $tt = Template->new({ INCLUDE_PATH => "$FindBin::Bin/../ttlib" });
my $html;
$tt->process('talk.tt', { object => $second }, \$html) or die $tt->error;
like($html, qr/July 2001 \(exact day not recorded\)/, 'qualified date reaches the talk page');
like($html, qr{href="https://example.com/slides\?a=1&amp;b=2">Slides</a>}, 'delivery slide link is escaped');
like($html, qr{href="https://example.com/video">Video</a>}, 'delivery video link is visible');
like($html, qr{property="og:image" content="https://talks.davecross.co.uk/images/modern-perl.png"},
  'URL overrides retain the original title-based image filename');

my $quoted = $schema->resultset('Talk')->create({ title => 'Perl & "History"', talk_type_id => 2 });
$tt->process('talk.tt', { object => $quoted }, \$html) or die $tt->error;
like($html, qr{<title>Perl &amp; &quot;History&quot;</title>}, 'document title is escaped');
like($html, qr{property="og:title" content="Perl &amp; &quot;History&quot;"}, 'quoted title cannot break metadata');
done_testing;
