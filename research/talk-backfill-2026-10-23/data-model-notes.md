# Data model notes for backfilling talks

Inspected on 24 October 2026 using the live SQLite schema, DBIx::Class models
and templates. Updated after implementing issue #26: the database now has an
optional presentation-title column. The confirmed historical backfill has now
also been imported; see the [import result](import-result.md).

## What already works

- A [talk](../../lib/Talks/Schema/Result/Talk.pm) represents reusable material,
  with its title, description and talk type.
- A [presentation](../../lib/Talks/Schema/Result/Presentation.pm) is a delivery
  of one talk at an event, with its own datetime and optional slide/video URLs,
  PDF URL and Google Slides/YouTube identifiers.
- Several presentations can therefore point to the same talk, including
  shorter versions. Different slide decks can already be stored per delivery.
- A presentation can now override the talk title with its own nullable `title`.
  `display_title` uses a nonblank override or falls back to the talk title.
  Event listings and recent-presentation cards use this title, and the talk
  page shows alternate titles beside their delivery's event and date.

## What is missing

The presentation table still has no description/notes, duration or explicit
extract flag. Talk type also belongs to the talk, so a tutorial and
its shorter talk extracts cannot have different types on their delivery rows.
There is no relationship between a talk and another talk from which it is
extracted.

The [talk page](../../ttlib/talk.tt) lists each delivery's event and datetime,
and any alternate title. It does not have a separate extract flag or offer all
slide variants beside their corresponding deliveries. Its embedded
media are selected through the talk's `get_a_thing` helper: a talk-level value
takes precedence, otherwise it returns the first populated presentation value.
Storing several decks therefore does not currently make them all visible.

## Confirmed example: Idiomatic Perl

Dave confirmed that T010 and T011 are extracts from **T106**, correcting his
initial reference to T006. All three already have a proposed link to existing
talk **21 — Idiomatic Perl**. Keep three presentation records attached to that
talk, with the two London deliveries labelled as extracts. This relationship
does not require creating duplicate talk records or a database link to the
German delivery itself: T106 is the review reference for the fuller material.

The research files retain the confirmed relationships using `extract_of_id`
and `extract_relationship_review`. Those fields are research metadata, not
columns currently available in the site database. Dates and delivery review
states remain as previously recorded.

## Separate talks that share material

Dave's Overloading/Tieing decision differs from the Idiomatic Perl extracts:

- T013 (Overload.pm) and T014 (Overloading in Perl) share one separate talk,
  recorded as G002, with two deliveries and minor variations.
- T019 (Tieing) is another separate talk.
- T016 remains a delivery of the full tutorial, existing talk 22.

Dave suspects both shorter talks are extracts of the full tutorial material,
but explicitly wants to preserve these separate talk identities. The current
database can represent the three talks and their deliveries. It cannot
represent a structured derivation relationship between them; for now the
research files retain that probable relationship and the import decision.
Do not infer that an `extract_of_id` requires merging entries into one talk.

## Title support implemented; other possible additions

Optional presentation title overrides from
[GitHub issue #26](https://github.com/davorg/talks/issues/26) are implemented
locally, covering both the Idiomatic Perl extracts and G001's advertised titles.
The [migration instructions](../../db/migrations/README.md) explain how to
upgrade older archive copies. Presentation overrides have now been populated
during backfill, with the accepted date correction applied to presentation 18.

Optional presentation **notes** and an **is_extract** flag, together with
individual media links beside each delivery, remain possible future additions.
For now an advertised title can label a delivery as an extract while all its
presentations stay attached to the same underlying talk.

If delivery durations or tutorial-versus-talk classifications need to appear
on the site, give presentations optional duration and type overrides too.
These are separate choices from recording a delivery as an extract.

Retain the existing talk/presentation structure for these import decisions.
If the relationship between separate talks needs to appear on the site, a
future optional talk-to-talk relationship could express that Overloading and
Tieing are likely derived from the combined tutorial. That is separate from
issue #26's presentation title overrides, and the derivation should remain
qualified until confirmed.
