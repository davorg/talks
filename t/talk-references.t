use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use File::Copy qw(copy);
use File::Temp qw(tempdir);
use Template;
use Test::More;
use Talks::Schema;

my $root = "$FindBin::Bin/..";
my $tmp = tempdir(CLEANUP => 1);
copy("$root/db/talks.db", "$tmp/talks.db") or die "Copy database: $!";
my $schema = Talks::Schema->connect("dbi:SQLite:dbname=$tmp/talks.db");
my $type = $schema->resultset('TalkType')->find_or_create({ type => 'test' });
my $tt = Template->new({ INCLUDE_PATH => "$root/ttlib" });

sub render_talk {
  my (%fields) = @_;
  my $talk = $schema->resultset('Talk')->create({
    title => 'Reference rendering test',
    talk_type_id => $type->id,
    %fields,
  });
  for my $kind (qw(article website code)) {
    $talk->create_related('talk_links', {
      link => "https://example.com/$kind",
      type => $kind,
      title => "An $kind reference",
    });
  }
  my $html;
  $tt->process('talk.tt', { object => $talk }, \$html) or die $tt->error;
  return $html;
}

subtest 'references alongside video' => sub {
  my $html = render_talk(youtube_code => 'test-video');
  like($html, qr/id="nav-references-tab"/, 'References tab is rendered');
  like($html, qr/id="nav-references"/, 'References pane is rendered');
  for my $kind (qw(article website code)) {
    like($html, qr{href="https://example\.com/$kind"}, "$kind link is rendered");
    like($html, qr/An $kind reference/, "$kind title is rendered");
  }
  like($html, qr/class="tab-pane fade show active" id="nav-video"/,
    'video remains the initially visible pane');
};

subtest 'references without media' => sub {
  my $html = render_talk();
  like($html, qr/class="nav-link active" id="nav-references-tab"/,
    'References is the active tab');
  like($html, qr/class="tab-pane fade show active" id="nav-references"/,
    'References is the initially visible pane');
  for my $kind (qw(article website code)) {
    like($html, qr{href="https://example\.com/$kind"}, "$kind link is rendered");
  }
};

subtest 'no reference links' => sub {
  my $talk = $schema->resultset('Talk')->create({
    title => 'No references test',
    talk_type_id => $type->id,
    youtube_code => 'test-video',
  });
  my $html;
  $tt->process('talk.tt', { object => $talk }, \$html) or die $tt->error;
  unlike($html, qr/id="nav-references(?:-tab)?"/, 'no empty References tab or pane');
  like($html, qr/id="nav-video"/, 'video still renders');
};

done_testing;
