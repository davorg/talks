# Talks by Dave Cross

A Perl static-site generator and database for Dave Cross's talk archive at
<https://talks.davecross.co.uk/>. It collects talks, their presentations at events,
slides, videos, descriptions, Markdown summaries, and reference links. Visitors
can browse by title, year, event, or talk type.

The application runs at build time. The resulting site consists of HTML, CSS,
images, and PDFs; serving it does not require Perl or a database server.

## Repository layout

| Path | Purpose |
| --- | --- |
| `bin/mk-talks` | Build entry point; constructs `Talks` and calls `run`. |
| `bin/migrate-presentation-title` | Adds optional presentation titles to an older archive database. |
| `bin/import-talk-backfill` | Dry-run/apply importer for the confirmed historical presentation catalogue. |
| `lib/Talks.pm` | Loads configuration, connects to SQLite, copies assets, renders pages, and writes the sitemap. |
| `lib/Talks/IndexPage.pm` | Page metadata and output filenames for index pages. |
| `lib/Talks/Schema.pm` | DBIx::Class schema and database connection helper. |
| `lib/Talks/Schema/Result/` | Database mappings, relationships, slugs, page metadata, and media helpers. |
| `lib/Talks/Schema/ResultSet/` | Queries for ordering, active years, recent presentations, and recent additions. |
| `db/talks.db` | Committed SQLite database containing the archive. |
| `db/talks.sql`, `db/talks.dat` | Older schema definition and starter data; see the schema drift issue below. |
| `db/dbic.conf` | DBIx::Class::Schema::Loader configuration for generating ORM mappings. |
| `db/migrations/` | Supported incremental schema changes and migration instructions. |
| `research/talk-backfill-2026-10-23/` | Reviewed sources, grouping decisions and source-to-database import results. |
| `ttlib/` | Template Toolkit templates; `page.tt` is the shared wrapper. |
| `static/` | Source assets, custom domain file, robots policy, and `.nojekyll`. |
| `docs/` | Committed generated site, arranged for GitHub Pages hosting. |
| `cpanfile` | Perl dependency manifest; currently incomplete. |
| `.github/workflows/copilot-setup-steps.yml` | Sets up Perl 5.40 and installs modules for Copilot; does not build or deploy the site. |

## Build and preview

Run commands from the repository root: configuration, template, asset, and
database paths are relative to the current directory.

As written, the code needs **Perl 5.40 or later** because it uses native `class`
syntax and `:reader` field attributes. The `use v5.36` declarations do not express
that requirement correctly. A full build was verified on Perl 5.42.3.

Install the modules in the manifest, plus the currently undeclared runtime
dependencies:

```sh
cpanm --installdeps .
cpanm Pandoc DBD::SQLite DateTime::Format::SQLite
```

Install the **Pandoc executable** using your operating system's package manager
as well. The Perl `Pandoc` module calls it to convert talk summaries to HTML.
These instructions account for the missing requirements identified in the
review; a fresh dependency installation has not yet been verified.

If `talks.json` is absent, create it with the production site URL:

```json
{
  "domain": "https://talks.davecross.co.uk"
}
```

Then build:

```sh
perl bin/migrate-presentation-title
mkdir -p docs
perl -Ilib bin/mk-talks
```

The committed database already has the optional presentation-title column.
The migration command is safe to repeat and is needed when using an older
archive copy. See [database migrations](db/migrations/README.md) for backups
and migration of a different database file.

The directory creation works around the current failure when the output root
does not exist. A build overwrites generated files in `docs/`; inspect the diff
before publishing.

Run the regression checks with:

```sh
prove -Ilib t
```

For a local preview:

```sh
python3 -m http.server 8000 --directory docs
```

Open <http://localhost:8000/>. Serving the output root is necessary because
navigation and asset links use root-relative URLs.

## Configuration

`Talks` reads an optional `talks.json` in the working directory. This file is not
currently tracked. Supported keys and defaults are:

| Key | Default | Effect |
| --- | --- | --- |
| `static_path` | `static` | Asset source directory; copying also explicitly reads its `images` and `pdf` directories. |
| `output_path` | `docs` | Generated output directory; currently must already exist. |
| `ttlib_path` | `ttlib` | Template include directory. |
| `domain` | Empty string | Prefix for sitemap locations; set it to an absolute site URL without a trailing slash. |
| `tt_config` | Include/output paths derived from the keys above | Replaces the whole Template Toolkit configuration, rather than merging it. |

Changing `domain` currently changes only the sitemap. Canonical and Open Graph
URLs in `page.tt`, `static/CNAME`, and `static/robots.txt` independently name the
production domain.

The generator always opens `db/talks.db`. The separate `get_schema` helper
validates `TALKS_DB_FILE` but currently ignores it when connecting
([#24](https://github.com/davorg/talks/issues/24)).

## Content and generation

A **talk** is the reusable subject or slide deck, with a talk type and optional
description, summary, media, image flag, and reference links. A **presentation**
records a delivery of a talk at an event, with its datetime, optional media,
and an optional title override. A nonblank presentation title is displayed on
event pages and recent-presentation cards, and beside that delivery on the talk
page when it differs from the talk title. A missing or blank title falls back
to the talk title. A qualified date label preserves uncertain dates without
inventing a day or time. Talks can have an explicit URL slug when distinct
titles would otherwise collide, including Modern Perl and Modern PERL.
An event belongs to an event series and year, and can have a venue or be online.
Venues link through cities to countries.

The build copies static assets, generates the homepage and year/event/type/title
indexes, renders event/type/talk detail pages, then writes `sitemap.xml`. There
are no individual year detail pages. The homepage queries recent presentations
and recently added talks; additions are ordered by descending database ID.

The archive has **80 talks and 115 presentations** after the confirmed
historical backfill. See the [import result](research/talk-backfill-2026-10-23/import-result.md)
for all research IDs and their database records.

Talk media helpers prefer fields on the talk, then search its presentations.
Templates embed Google Slides, YouTube, and PDFs. Summaries are converted from
Markdown with Pandoc. Reference links support article, website, and code icons.
Each delivery also shows its own available slide/video links. A build fails
if two talks would overwrite the same output path.
The shared page uses Bootstrap from a CDN, Google Fonts, and Google Analytics.

The reviewed backfill has a repeatable importer requiring Python 3.9 or later,
using only its standard library. There is no content editor. Import commands
and schema changes are documented under [database migrations](db/migrations/README.md).
Content is stored in SQLite, so use a database tool or the ORM to update
it, then rebuild. Keep backups before editing the archive. **Do not recreate the
current archive using `talks.sql` and `talks.dat`:** the schema is out of date and
the data file is only a small seed, not a complete archive export
([#19](https://github.com/davorg/talks/issues/19)).

Many ORM files were generated by Schema::Loader. Their comments mark generated
sections and the custom code preserved beneath them; inspect both before
regenerating mappings.

See [the repository review](REPOSITORY-REVIEW.md) for verified problems,
reproduction evidence, and the associated GitHub issues.
