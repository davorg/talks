use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use DBI;
use File::Copy qw(copy);
use File::Temp qw(tempdir);
use IPC::Open3;
use Symbol qw(gensym);
use Template;
use Test::More;
use Talks::IndexPage;
use Talks::Schema;

my $root = "$FindBin::Bin/..";
my $tmp = tempdir(CLEANUP => 1);

sub migrate {
  my ($file) = @_;
  my $err = gensym;
  my $pid = open3(undef, my $out, $err,
    $^X, "$root/bin/migrate-presentation-title", $file);
  my $stdout = do { local $/; <$out> } // '';
  my $stderr = do { local $/; <$err> } // '';
  waitpid($pid, 0);
  return ($? >> 8, $stdout . $stderr);
}

subtest 'migration preserves older data and can be repeated' => sub {
  my $file = "$tmp/legacy.db";
  my $dbh = DBI->connect("dbi:SQLite:dbname=$file", '', '', { RaiseError => 1 });
  $dbh->do('CREATE TABLE presentation (id INTEGER PRIMARY KEY, talk_id INTEGER, datetime TEXT)');
  $dbh->do(q{INSERT INTO presentation VALUES (1, 21, '2004-10-13 13:00:00')});
  $dbh->disconnect;

  my ($status, $output) = migrate($file);
  is($status, 0, "older database migrates: $output");
  $dbh = DBI->connect("dbi:SQLite:dbname=$file", '', '', { RaiseError => 1 });
  is_deeply($dbh->selectall_arrayref('SELECT * FROM presentation'),
    [[1, 21, '2004-10-13 13:00:00', undef]], 'existing row survives with a NULL override');
  $dbh->do(q{UPDATE presentation SET title = 'Idiomatic Perl (extract)' WHERE id = 1});
  $dbh->disconnect;

  ($status, $output) = migrate($file);
  is($status, 0, "repeat migration succeeds: $output");
  $dbh = DBI->connect("dbi:SQLite:dbname=$file", '', '', { RaiseError => 1 });
  is($dbh->selectrow_array('SELECT title FROM presentation WHERE id = 1'),
    'Idiomatic Perl (extract)', 'repeat migration preserves an existing override');
  is($dbh->selectrow_array('PRAGMA integrity_check'), 'ok', 'database remains valid');
  $dbh->disconnect;

  ($status, $output) = migrate("$tmp/missing.db");
  isnt($status, 0, 'a missing database is rejected');
  ok(!-e "$tmp/missing.db", 'migration does not create an empty archive');
};

subtest 'migration rejects an incompatible existing title column' => sub {
  my $file = "$tmp/incompatible.db";
  my $dbh = DBI->connect("dbi:SQLite:dbname=$file", '', '', { RaiseError => 1 });
  $dbh->do('CREATE TABLE presentation (id INTEGER PRIMARY KEY, title TEXT NOT NULL)');
  $dbh->do(q{INSERT INTO presentation VALUES (1, 'Keep this title')});
  $dbh->disconnect;
  my ($status, $output) = migrate($file);
  isnt($status, 0, 'incompatible schema is rejected');
  like($output, qr/presentation\.title must be nullable TEXT/, 'failure explains the schema mismatch');
  $dbh = DBI->connect("dbi:SQLite:dbname=$file", '', '', { RaiseError => 1 });
  is($dbh->selectrow_array('SELECT title FROM presentation'),
    'Keep this title', 'failed migration preserves the data');
  $dbh->disconnect;
};

copy("$root/db/talks.db", "$tmp/archive.db") or die "Copy database: $!";
my ($status, $output) = migrate("$tmp/archive.db");
die "Cannot migrate test archive: $output" if $status;
my $schema = Talks::Schema->connect("dbi:SQLite:dbname=$tmp/archive.db");
my $type = $schema->resultset('TalkType')->find({ type => 'talk' });
my $year = $schema->resultset('Year')->find_or_create({ year => 2099 });
my $event = $schema->resultset('Event')->create({
  name => 'Presentation titles test',
  start_date => '2099-01-01',
  year_id => $year->id,
  event_series_id => 1,
  is_online => 1,
});
my $talk = $schema->resultset('Talk')->create({
  title => 'Idiomatic Perl',
  talk_type_id => $type->id,
});
my $canonical_url = $talk->url_path;
my $first = $talk->create_related('presentations', {
  event_id => $event->id, datetime => '2099-01-01 09:00:00',
});

subtest 'title fallback' => sub {
  for my $blank (undef, '', ' ', "\t\r\n") {
    $first->update({ title => $blank });
    is($first->display_title, 'Idiomatic Perl', 'NULL or blank uses the talk title');
  }
  $first->update({ title => '0' });
  is($first->display_title, '0', 'a nonblank false-valued string is still an override');
  $first->update({ title => 'Idiomatic Perl (extract)' });
  is($first->display_title, 'Idiomatic Perl (extract)', 'nonblank title overrides the talk title');
  is($talk->discard_changes->title, 'Idiomatic Perl', 'canonical talk title is unchanged');
  is($talk->url_path, $canonical_url, 'canonical talk URL is unchanged');
};

my $second = $talk->create_related('presentations', {
  event_id => $event->id, datetime => '2099-01-01 11:00:00',
  title => 'Idiomatic Perl <advanced> & "examples"',
});
my $plain = $talk->create_related('presentations', {
  event_id => $event->id, datetime => '2099-01-01 13:00:00',
});
my $same = $talk->create_related('presentations', {
  event_id => $event->id, datetime => '2099-01-01 15:00:00',
  title => $talk->title,
});
my $escaped = 'Idiomatic Perl &lt;advanced&gt; &amp; &quot;examples&quot;';
my $tt = Template->new({ INCLUDE_PATH => "$root/ttlib" });

sub render {
  my ($template, $vars) = @_;
  my $html;
  $tt->process($template, $vars, \$html) or die $tt->error;
  return $html;
}

subtest 'event listings use each delivery title and the shared talk URL' => sub {
  my $html = render('event.tt', { object => $event });
  like($html, qr{href="\Q$canonical_url\E">Idiomatic Perl \(extract\)</a>},
    'extract links to the canonical talk');
  like($html, qr{href="\Q$canonical_url\E">\Q$escaped\E</a>},
    'another delivery uses its own escaped title');
  like($html, qr{href="\Q$canonical_url\E">Idiomatic Perl</a>},
    'delivery without override falls back to the canonical title');
  unlike($html, qr/<advanced>/, 'title markup is not interpreted as HTML');
};

subtest 'recent presentation cards use overrides but recent additions use talk titles' => sub {
  my $index = Talks::IndexPage->new(
    title => 'Talks by Dave Cross', url_path => '/', description => 'Talk archive');
  my $html = render('index.tt', {
    object => $index,
    recent_presentations => [$first, $second, $plain],
    recent_additions => [$talk],
  });
  like($html, qr{class="card-title">Idiomatic Perl \(extract\)</h5>}, 'recent card uses override');
  like($html, qr{class="card-title">\Q$escaped\E</h5>}, 'recent title is escaped');
  my ($recent, $added) = split /<h2>Recently Added Talks<\/h2>/, $html, 2;
  like($recent, qr{class="card-title">Idiomatic Perl</h5>}, 'recent card falls back without an override');
  like($added, qr{class="card-title">Idiomatic Perl</h5>}, 'recently added talk keeps the canonical title');
  unlike($added, qr/Idiomatic Perl \(extract\)|\Q$escaped\E/, 'delivery titles do not replace talk-based cards');
  like($html, qr{href="\Q$canonical_url\E" class="btn btn-primary"}, 'card links to the shared talk');
};

subtest 'talk page annotates only alternate delivery titles' => sub {
  my $html = render('talk.tt', { object => $talk });
  like($html, qr{<h1[^>]*>Idiomatic Perl</h1>}, 'talk page heading stays canonical');
  like($html, qr{rel="canonical" href="https://talks\.davecross\.co\.uk\Q$canonical_url\E"},
    'canonical metadata URL is unchanged');
  like($html, qr{\Q@{[$first->datetime]}\E[^<]*Idiomatic Perl \(extract\)</li>},
    'alternate title appears alongside its delivery date');
  like($html, qr{\Q@{[$second->datetime]}\E[^<]*\Q$escaped\E</li>},
    'alternate title is escaped on the talk page');
  for my $presentation ($plain, $same) {
    like($html, qr{\Q@{[$presentation->datetime]}\E</li>},
      'no duplicate title when override is absent or matches the talk');
  }
};

subtest 'talk title and type indexes stay canonical' => sub {
  my $index = Talks::IndexPage->new(
    title => 'Talks by Title', url_path => '/talk/', description => 'Talk archive');
  my $html = render('talks.tt', { object => $index, talks => [$talk] });
  like($html, qr{href="\Q$canonical_url\E">Idiomatic Perl</a>}, 'title index uses canonical title');
  unlike($html, qr/Idiomatic Perl \(extract\)|\Q$escaped\E/, 'no delivery titles in title index');
  $html = render('type.tt', { object => $type });
  like($html, qr{href="\Q$canonical_url\E">Idiomatic Perl</a>}, 'type index uses canonical title');
  unlike($html, qr/Idiomatic Perl \(extract\)|\Q$escaped\E/, 'no delivery titles in type index');
};

done_testing;
