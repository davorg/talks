# Backfilling Dave Cross's talks

Research completed on **23 October 2026**, against repository commit
`141542a0f81c79111058165c8ae1f3af36c76882`. The existing database contained
**23 talk records and 25 presentations** at that baseline.
Dave completed both checklists on **24 October 2026**: **90 missing
presentations** and **16 existing matches/metadata checks** are confirmed,
with the recorded corrections and qualifications.

**Imported on 24 October 2026:** 57 talks and 90 presentations added. The
archive now has **80 talks and 115 presentations**. See the
[import result and database-ID mapping](import-result.md). The catalogue's
archive-status fields retain the pre-import classification for provenance.

## Start here

- [Slides and video recovery checklist](media-recovery.md) — 32 discovered
  media/material links, two further archival leads, and an appendix of 38
  existing archive references. The [CSV tracker](media-recovery.csv) includes
  status and recovered-file columns. Source/programme links can help with
  descriptions too.
- [Missing presentations: review checklist](review.md) — **90 candidate
  presentations**, with checkboxes, dates, event/location, evidence, media links,
  and questions. This is the main file to read and annotate.
- [Already represented and metadata checks](existing-and-corrections.md) —
  **16 externally sourced entries** that appear to match the existing archive,
  including a date discrepancy. These are not proposed as extra presentations.
- [Resolved uncertain leads](uncertain-leads.md) — all three reviewed:
  two dropped and the UKUUG Perl Teach-In confirmed in the main checklist.
- [Additional public-course advertisements](training-announcements.md) —
  **11 advertised courses**, outside the counts above, for a separate decision
  about whether public training should be included.
- [Search coverage and remaining gaps](research-log.md) — what was checked and
  where the evidence is still incomplete.
- [Data model notes](data-model-notes.md) — how talks and deliveries currently
  work, and proposed support for extracts, advertised titles and slide variants.
- [CSV catalogue](catalogue.csv) and [JSON catalogue](catalogue.json) — the same
  **106 active entries** in structured form, for sorting and import preparation.
- [Existing archive snapshot](existing-archive.json) — the database baseline used
  for comparison, including all 25 original presentations.
- [Source index](sources.json) — 121 evidence URLs, with access/provenance notes
  and the catalogue entries that use them.

## Review status and corrections

Both checklists are complete. Add any further corrections beneath the
relevant entry, or reply with its `T001`-style ID. The 11 public-course
advertisements remain separate and unconfirmed. IDs remain unique across
the lists.

A tick confirms the presentation happened; it does not magically resolve a
title, date, or grouping question already called out in the entry. Those details
still need your decision before import. The CSV's `review` column can instead
be set to `confirmed`, `rejected`, or `uncertain` if you prefer a spreadsheet.
The files do not automatically synchronise edits, so choose one review format.

IDs remain stable as new evidence is added. The follow-up entries T105–T108
appear in chronological order alongside the original entries; their numbers
therefore do not always increase down the page.
T012 and T017 were dropped after review and will not be reused.

All **106 active catalogue entries** have `review: confirmed`: the main
checklist's 90 missing presentations and the separately reviewed 16 existing
matches/metadata checks. The 11 public-course advertisements are outside
these confirmation batches. JSON's `review_batches` records both decisions;
JSON/CSV's `review_basis` retains their scope and qualifications. Existing
matches must not become duplicate presentations. The confirmed data has now
been imported using `bin/import-talk-backfill`; repeated imports reuse the
recorded mappings. Source records remain unchanged for reproducibility.

## Title cleanup

Organiser-added session labels and scheduling instructions have been removed
from the working titles, as Dave requested on 24 October 2026:

| ID | Cleaned title | Removed text |
| --- | --- | --- |
| T050 | The "M" Word | KEYNOTE: |
| T052 | The Professional Programmer | (See Events) |
| T064 | Introducing Modern Perl | TEACHING CLASS \| |
| T067 | Modern Core Perl | [[TRAINING SESSION]] |
| T078 | Modern Perl for Non-Perl Programmers | : See schedule for breaks |

JSON and CSV retain the original wording in `programme_title`, and each
checklist entry records the cleanup. Source-page titles in the evidence index
are unchanged. Session types, substantive subtitles, part/day numbers, dates,
and delivery review states are preserved. Matching cleaned titles are not
implicitly merged into groups.

## What a record means

Each entry is a **presentation candidate**, not necessarily a distinct talk.
For example, “Matt's PSGI Archive” turns up at LPW 2012, Milton Keynes in May
2013, and YAPC Europe in August 2013. Those are three deliveries, likely linked
to one talk. Multi-day courses and split programme slots are kept visible and
flagged for grouping, rather than silently collapsed.

`missing_talk` means the candidate title did not exactly match a title already
in the database. It does **not** mean every such row needs a separate new talk
record: many share a title or may be revisions of another talk.
`missing_delivery` means the title matched an existing talk but the delivery
was absent. `already_present` and `metadata_check` avoid adding duplicates.
Proposed matches are pointers for review, not automatic merges.

Programme entries establish that a presentation was scheduled or accepted;
they do not prove delivery. Post-event reports are stronger evidence that it
happened. “Accepted listing” often means that a lightning talk has an accepted
Act entry but no individual datetime. These are retained for you to confirm.

`date_precision` distinguishes exact days, months, years, and event ranges.
Where a range is shown, its first date must **not** be imported as the talk's
date without confirmation. Times are local programme times. A few group
announcements give only the meeting start; the notes explicitly identify those.

The linked slides and videos are discovery pointers. Some old slide addresses
are dead and may require the Internet Archive or your own copies. A link in the
catalogue does not mean that an embed was tested.

## Particularly useful finds

- Your [2024 retrospective](https://perlhacks.com/2024/04/collecting-talks/) dates
  your first public conference talks to YAPC Europe in September **2000**: a
  data-munging talk and a Symbol::Approx::Sub lightning talk. No earlier
  presentation was established by this search.
- **Birmingham, 26 February 2003:** two talks at one visit, “Overloading in Perl”
  and “Perl For The People”. The [live event page you supplied](https://birmingham.grango.org/tech/73)
  gives the QPC venue and links to both sets of slides.
- **Belfast, 17 November 2003:** the [archived organiser page](https://web.archive.org/web/20041207081455/http://belfast.pm.org/meetings/2003/)
  advertises your Tieing talk at BT Tower. This is the Mongers meeting, separate
  from YAPC Europe 2004 in the same city.
- **Milton Keynes:** seven candidate presentations across six visits, from
  March 2006 to May 2013. The two October 2009 talks were at the same meeting.
- **Italian Code Jam, 9 October 2004:** your [same-day report](https://blog.dave.org.uk/2004/10/italian-code-ja.html)
  identifies a high-level Template Toolkit introduction.
- **German Perl Workshop, February 2002:** the [archived official timetable](https://web.archive.org/web/20020405194515/http://www.perlworkshop.de/2002/times.epl)
  confirms both titles you remembered: “Idiotic Perl”, 14 February at 14:00,
  and the “Idiomatic Perl” tutorial, 15 February at 09:00. These are T105–T106;
  the programme resolves the tentative recollection of 2001 to **2002**.
- **FOSDEM, 22 February 2004:** you confirmed T020’s title was simply
  “Perl”. The programme gives 15:00–16:00 in the Lameere room; your [organiser interview](https://archive.fosdem.org/2004/index/interviews/interviews_cross.html)
  describes the subject as Perl's current state and future.
- **Perl Whirl ’04 / Geek Cruises, 10–17 October 2004:** the [organiser's seminar page](https://www.insightcruises.com/seminar/pw4_seminar.htm)
  names you for “Idiomatic Perl” and “Tieing and Overloading Objects in Perl”.
  Both already exist as presentations 23–24; T107–T108 preserve the new evidence
  without proposing duplicates. The cruise dates fit your recollection of
  going straight from the Italian Code Jam.
- **Belgian Perl Workshop, 27 October 2007:** the [archived programme](https://web.archive.org/web/20110809192310/http://www.perlworkshop.be/bpw2007/talk/797)
  names “Teach-In Extract - OO Perl”, 09:30, 40 minutes.
- **UKUUG Spring Conference, 31 March 2008:** you confirmed the one-day
  “Perl Teach-In”, T035. Your [archived abstract](https://web.archive.org/web/20221207023139/https://www.ukuug.org/events/spring2008/talk_abstracts.html#perl_tutorial)
  and the organiser's timetable identify the full-day tutorial at the
  Birmingham Conservatoire, starting at 10:30.
- The Act speaker profiles supplied 53 entries in total, including **39 missing
  deliveries** before the supplementary sources were added. The tutorial pages
  and your retrospectives also recover courses absent from those profiles.

## Talk grouping recorded during review

**G001 — T003, T004, T006 and T068:** Dave is **95% sure** the first three
are one talk under the titles “Perl For The People”, “Increasing Perl Use”,
and the long YAPC 2001 “A Modest Proposal” title. He confirmed **T068 — The
Perl Community - A Modest Proposal** (LPW 2011) is a lightly updated revival
of T006, revisiting his “greatest hits”. Prepare one talk with four separate
deliveries, preserving each recorded title and any slide variations. “Perl
For The People” is the provisional common title.

The specific T068-to-T006 revision relationship is confirmed and recorded in
JSON/CSV as `revision_of_id: T006` and `revision_relationship_review: confirmed`.
The original three-way grouping remains probable at Dave's stated 95%; this
later confirmation does not upgrade those earlier matches.

This is a probable grouping, not a completed merge. It is recorded in JSON's
`talk_groups` and the entries' `talk_group_id`; the CSV has a matching
`talk_group_id` column. Slide variations and individual delivery/date review
remain separate from this grouping decision.

**Confirmed extracts — T010 and T011:** Dave confirmed these are extracts
from **T106 — Idiomatic Perl**, correcting his initial reference to T006.
The JSON/CSV fields `extract_of_id` and `extract_relationship_review` retain
that relationship. All three already point to existing talk 21 for proposed
import; their dates and delivery review states are unchanged. The current
database can store separate deliveries and decks, and now supports optional
presentation titles to label extracts. Separate notes and extract flags remain
possible additions; see the
[data model notes](data-model-notes.md).

**G002 — T013 and T014:** Dave identifies “Overload.pm” and “Overloading in
Perl” as the same talk with minor variations. Keep their two deliveries under
one talk, with “Overloading in Perl” as a provisional common title.
**T019 — Tieing** stays a separate talk. Both shorter talks stay separate
from **T016 / existing talk 22 — Tieing and Overloading Objects in Perl**.

Dave suspects the three shorter deliveries are extracts of that tutorial
material; the derivation is recorded as probable. The JSON/CSV fields
`extract_of_id`, `extract_relationship_review`, and `import_as_separate_talk`
preserve the distinction between likely shared content and the explicit
decision to keep separate talk records. G002 still groups T013/T014 together;
delivery review states and dates are unchanged.

**G003 — T021 and T033:** Dave confirmed the Italian Code Jam introduction
(9 October 2004) and the Milton Keynes Template Toolkit introduction
(15 November 2007) are the same talk with slightly differing titles. Prepare
one talk with two deliveries, keeping both recorded titles. “Introduction to
the Template Toolkit” is the provisional common title; delivery review states
and dates are unchanged.

**G004 — T039 and T041:** Dave confirmed the London Perl Mongers history
talk at YAPC Europe 2008 (15 August) and LPW 2008 (29 November) is one talk.
Keep two deliveries, both advertised title variants and their respective
30- and 40-minute programme durations. The LPW title is the provisional common
title; individual delivery review states and dates are unchanged.

**G005 — T043 and T046:** Dave confirmed the CPAN reinvention talk at
London.pm (30 July 2009) and YAPC Europe in Lisbon (4 August 2009) is one talk.
Keep two deliveries, using the full London title as the provisional common
title and preserving the abbreviated YAPC programme title. Delivery review
states and dates are unchanged.

**G006 — T072 and T075:** Dave confirmed the 25 Years of Perl talk at
LPW 2012 (24 November) and YAPC Europe 2013 in Kyiv (12 August) is one talk.
Keep two deliveries, both advertised titles and the recording attached to
T075. The YAPC title is the provisional common title; dates and delivery
review states are unchanged.

## Decisions worth making before import

1. How to group the remaining alternate titles: “Perl Training” / “Teaching
   Perl” and the 2015 ebook-publishing talk. G001 and G002 record the decisions
   about the Perl For The People and Overloading variants above.
2. Whether conference tutorials split into two sessions should become one
   presentation or two, and whether public courses belong in this archive.
3. Whether to include the OpenTech and South London Geek Night talks on civic
   web projects and media scrutiny. They are technical-community presentations,
   but are not all about Perl.
4. Applied the accepted T093 correction during import: YAPC 2016
   “Error(s) Free Programming” is dated **25 August**, as its programme says,
   instead of **26 August** in existing presentation 18. The database date
   is now corrected.
5. How to resolve the separate duplicate talk records 7 and 13 before linking
   any future SEO-course deliveries (already tracked in issue #17).

The import applied the recorded grouping and title decisions, preserved the
existing matches and applied T093's accepted correction. The remaining items
above are possible future refinements; qualifiers and source evidence remain
available in the catalogue and database provenance. Review the separate
training advertisements before including them in a future import.
