# Database migrations

The committed `db/talks.db` includes the migrations listed here. Keep a backup
before migrating another copy of the archive. The migration scripts update the
existing database; they do not import talk records or rebuild the site.

## 001 — optional presentation title

```sh
cp /path/to/talks.db /path/to/talks.before-title.db
perl bin/migrate-presentation-title /path/to/talks.db
```

Omit the database argument to update this repository's `db/talks.db`. The
script adds a nullable `presentation.title` in a transaction, preserves existing
rows, and can be run again safely. It refuses to create a missing database.
Apply it before using the updated ORM or generator with an older archive copy.

Leave `presentation.title` NULL (or blank) to display the associated talk's
title. Set it to the delivery's advertised title to override that display:

```perl
$presentation->update({ title => 'Idiomatic Perl (extract)' });
$presentation->display_title; # Idiomatic Perl (extract)
$presentation->talk->title;  # Idiomatic Perl
```

Event listings and recent-presentation cards use the delivery title. A talk's
delivery list shows an alternate title beside its event and date. The talk's
own title, page heading, URL and talk-based indexes remain unchanged.

`001-presentation-title.sql` contains the underlying schema change. The script
checks whether it is needed before applying it. `db/talks.sql` also declares
the new column, but remains a legacy bootstrap schema with other differences
from the current archive ([issue #19](https://github.com/davorg/talks/issues/19)).
Do not recreate a populated archive from that file or from `db/talks.dat`.

## Reviewed historical backfill

The backfill importer requires Python 3.9 or later (standard library only):

```sh
python3 bin/import-talk-backfill --report /tmp/backfill-plan.json
python3 bin/import-talk-backfill --apply --report /tmp/backfill-result.json
```

The first command runs against an in-memory copy and leaves the archive
unchanged. `--apply` creates a SQLite backup alongside the database before
changing it. Use `--database PATH`, `--catalogue PATH`, `--backup PATH`, and
`--report PATH` to choose other files. An existing backup is never overwritten.

The import adds these optional metadata fields inside its transaction:

- `talk.url_slug`: a stable URL override for distinct titles which otherwise
  collide, including Modern Perl / Modern PERL. Existing URL paths are retained
  wherever possible; the two existing Googlejuice records remain separate.
- `presentation.date_label`: a readable qualified date. An unknown exact day
  leaves `datetime` NULL; a known day without a known time stores only its date.
  Meeting start times are not treated as presentation start times.
- `event.location_text`: known location text when the source does not name a
  specific venue. No placeholder venues or invented cities are created.
- `backfill_source`: maps each research ID to its presentation and retains the
  full reviewed JSON record, including evidence links, original programme
  titles, date precision, delivery type, durations and grouping qualifications.

All archive updates and provenance entries commit together, after integrity
and foreign-key checks. Repeating the same import reuses its recorded matches
without adding duplicates. Changed research records or missing previously
imported presentations cause an error rather than silently overwriting data.

The reviewed catalogue contains 90 missing deliveries and 16 existing matches.
The latter are reused, with the accepted T093 date correction applied to its
existing presentation. The 11 separately advertised public courses and two
rejected leads are excluded. Split course slots remain separate presentations
under one talk. Source evidence and explicit grouping decisions determine the
other matches; differently titled talks with uncertain identities remain
separate. Capitalisation is preserved, including the distinct Modern PERL talk.
