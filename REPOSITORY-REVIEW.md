# Repository review — 23 October 2026

Reviewed commit `00e752d` on `main`. The review covered tracked source files,
templates, assets, SQLite data, generated output, dependency declarations, and
the GitHub issue backlog. Existing untracked files were left untouched. No
application fixes or generated-site updates are included in this review.

## What the repository does

This is a small Perl publishing application for Dave Cross's talk archive.
DBIx::Class exposes a committed SQLite database; Template Toolkit renders a
static website into `docs/`. The repository includes the sources and published
output. There is no runtime web backend.

The archive currently contains 23 talk records, 25 presentations, 13 events,
5 event series, 4 talk types, and 3 reference links. Title-derived slugs produce
22 distinct talk pages because two talk records collide. A complete build emits
44 HTML pages: 5 indexes, 13 event pages, 4 type pages, and 22 talk pages.

The data model separates a talk from its deliveries. Event relationships provide
chronology and location; talk and presentation fields supply slides and videos.
Talk descriptions, Markdown summaries, and references enrich individual pages.
The README documents the directory layout, build, configuration, and editing
workflow.

## Validation performed

- `perl -Ilib -c bin/mk-talks` passed on the installed Perl 5.42.3.
- A temporary copy made from tracked files built successfully using the installed
  dependencies and an existing output root. The production domain configuration
  was also tested separately.
- A build after moving the output directory aside failed; creating the empty
  output root made the build succeed.
- `PRAGMA quick_check` returned `ok`; `PRAGMA foreign_key_check` returned no
  violations for the committed database.
- The SQL definition and starter data were loaded into an in-memory database
  and compared with columns needed by the current ORM.
- All 44 committed HTML pages were scanned for local `href` and `src` targets.
  The only missing targets found were six Bootstrap example favicon/manifest
  paths shared by every page.
- Regenerated output was compared with committed output. With the domain
  configured, only the MCP talk page differed: its References tab disappeared.
- Temporary data fixtures reproduced a missing summary-only panel and duplicate
  recent-talk results through the actual generator/ORM.
- The database connection helper was checked with alternate environment paths;
  its resulting DSN remained hard-coded.

The review did not install a clean dependency environment, exercise a browser,
check external resource availability, or inspect hosted GitHub Pages settings.
Build and data fixtures ran under `/tmp`, preserving the working-tree database
and generated site. There is no tracked automated test suite or normal
build-validation workflow; the sole workflow prepares Copilot dependencies.

## Confirmed problems and GitHub issues

### Current content regressions

**Reference links disappear on rebuild — [#16](https://github.com/davorg/talks/issues/16).**
`ttlib/talk.tt` checks `talk.talk_links.count`, but Template Toolkit sees the
relationship as a list. Rendering that expression for talk 23 yields an empty
value, while `.size` yields `3`. Rebuilding removes the References button and
pane from the MCP page, although its database rows and committed HTML contain
the links. Use a list-size check or an explicit helper throughout the template.

Follow-up implementation: the template now uses `.size` for all three reference
checks. `t/talk-references.t` covers links alongside media, references-only
talks, and talks without references, using the ORM and a temporary database.

**Duplicate slugs overwrite a talk page — [#17](https://github.com/davorg/talks/issues/17).**
Talk IDs 7 and 13 both have the title “Web Site Tune-Up - Improve Your
Googlejuice” and write to the same path. Their presentations are at The Perl
Conference 2018 and London Perl Workshop 2017 respectively. Only the 2017
presentation survives on the generated talk page. Resolve the duplicate records
or URLs and make the build reject path collisions instead of losing content.

### Setup and rebuild problems

**Incomplete runtime requirements — [#18](https://github.com/davorg/talks/issues/18).**
The manifest omits `Pandoc`, `DBD::SQLite`, and `DateTime::Format::SQLite`, and
does not declare the real Perl minimum. Native `class` and `:reader` require
Perl 5.40+ as used here, despite the source saying `use v5.36`.
`Feature::Compat::Class` is listed but never imported. Summary rendering also
needs the external Pandoc executable. The current workstation supplies these
dependencies, so a successful local build does not verify clean installation.

**Bootstrap schema drift — [#19](https://github.com/davorg/talks/issues/19).**
The SQL file creates `event.description` instead of the current `name`, omits
online-event support and newer talk/presentation fields, and defines a
presentation type reference to a nonexistent `type` table. Loading both SQL
files succeeds, but querying `event.name` or `talk.talk_type_id` fails. The binary
database passes integrity checks; the schema source needs to catch up.

**Missing domain produces relative sitemap locations — [#20](https://github.com/davorg/talks/issues/20).**
The production domain is supplied by an untracked local `talks.json`. Building
only tracked files emits locations such as `<loc>/event/</loc>`; adding the
domain restores absolute URLs. Canonical/OG metadata, CNAME, and robots.txt
independently hard-code the production hostname. Supply a reproducible default
or validate configuration and use one site URL consistently.

**Output root must already exist — [#21](https://github.com/davorg/talks/issues/21).**
Static copying precedes template rendering and does not create the output root.
Without `docs/`, the observed first copy fails with “No such file or directory”.
This also affects new custom output paths. Create destination parents before
copying assets.

### Additional behavior bugs

**Summary-only content is hidden — [#22](https://github.com/davorg/talks/issues/22).**
The outer tab condition considers media and reference counts, but not summaries.
A fixture with a summary and no media builds successfully while omitting the
summary entirely. Separately, the Summary pane never receives the active state,
so after the reference-count fix, summary-plus-reference pages without media
would start without an active panel. Include all content types and activate the
first available tab consistently.

**Recent-talk cards can repeat one talk — [#23](https://github.com/davorg/talks/issues/23).**
The query matches talk IDs and maximum datetimes independently, rather than as
pairs. With talk 1 presented on 23 and 22 October and talk 2 on 22 October, it
returns talk IDs `1, 1, 2`. An older presentation qualifies because it matches
another talk's latest datetime. Correlate the maximum with its talk and choose
one presentation deterministically when datetimes tie.

**Database environment path is ignored — [#24](https://github.com/davorg/talks/issues/24).**
`Talks::Schema::get_schema` validates `TALKS_DB_FILE`, then connects to
`db/talks.db` regardless. Callers expecting an alternate database can therefore
access the wrong archive. The generator also uses a separate hard-coded
connection. Honor the selected file or remove the misleading helper contract.

## Existing issue reused

[#11: Remove/fix cargo culted HTML](https://github.com/davorg/talks/issues/11)
already covers leftover template markup. The shared wrapper still requests
these nonexistent resources on all 44 pages:

```text
/docs/5.0/assets/img/favicons/apple-touch-icon.png
/docs/5.0/assets/img/favicons/favicon-32x32.png
/docs/5.0/assets/img/favicons/favicon-16x16.png
/docs/5.0/assets/img/favicons/manifest.json
/docs/5.0/assets/img/favicons/safari-pinned-tab.svg
/docs/5.0/assets/img/favicons/favicon.ico
```

Replace them with real site assets or remove the stale references. No duplicate
issue was opened. Other existing feature requests were left unchanged.

## Suggested order

Fix the disappearing reference links and overwritten talk page first because
they affect current content. Next make dependencies, configuration, and the SQL
schema reproducible. Address clean-output builds, tab selection, recent-talk
queries, and database selection alongside focused regression checks.
