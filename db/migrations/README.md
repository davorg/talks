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
