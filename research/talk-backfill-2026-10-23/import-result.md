# Historical talk backfill — import result

Imported on **24 October 2026** after both review checklists were confirmed.

**57 talks and 90 presentations added**, plus 54 events. The archive now has **80 talks, 115 presentations and 67 events**. All 25 original presentations and 23 original talk records remain.

The 16 existing matches were reused. T093 corrects presentation 18 to **25 August 2016, 15:05**. Presentation title overrides retain the accepted advertised titles, including the Idiomatic Perl extracts.

Modern Perl (OpenTech 2010) and Modern PERL (YAPC Europe 2015) remain distinct, as Dave clarified. Their pages are `/talk/modern-perl/` and `/talk/modern-perl-2015/`. Both legacy Googlejuice talk records remain; record 13 now uses `/talk/web-site-tune-up-improve-your-googlejuice-2017/` so it cannot overwrite record 7.

All listed split tutorial slots remain separate presentations under their shared course. Other identical titles and trivial punctuation variants share talks; approved groups and title aliases are applied. Teaching Perl / Perl Training and the provisional Writing Books talk remain separate where identity is uncertain.

Eight newly imported presentations have no recovered exact day. Their datetime remains NULL and the website displays the known month/range. Known dates without recovered times are date-only. Meeting start times are not imported as talk times. Missing named venues retain the known location without placeholder venue records.

Evidence, original programme titles, delivery kinds/durations, precision, notes and qualifications are retained in the database’s `backfill_source` table. The 11 unreviewed public-course advertisements and two rejected leads are excluded.

The pre-import backup is local at `db/talks.db.before-backfill-2026-10-24.bak`. Repeating the import produces no additional rows. The original review catalogue is kept unchanged so its recorded import fingerprints remain reproducible; its archive-status fields describe the pre-import baseline.

Tests, a full site build, SQLite integrity/foreign-key checks and internal archive-link checks passed. The build rejects duplicate talk output paths.

- [Detailed JSON result](import-result.json)
- [CSV source-to-database mapping](import-result.csv)
- [Importer and migration instructions](../../db/migrations/README.md)

## Source-to-database mapping

| Research ID | Talk ID | Presentation ID | Event ID | Action | Display title |
| --- | --- | --- | --- | --- | --- |
| T001 | 24 | 26 | 14 | new presentation | Data Munging with Perl |
| T002 | 25 | 27 | 14 | new presentation | Symbol::Approx::Sub |
| T003 | 26 | 28 | 15 | new presentation | Perl For The People |
| T004 | 26 | 29 | 17 | new presentation | Increasing Perl Use |
| T005 | 27 | 30 | 17 | new presentation | Why Perl Advocacy is a Bad Idea |
| T006 | 26 | 31 | 18 | new presentation | Perl for the People: A Modest Proposal for Increasing Perl Usage Using a Combination of Legal and Technological Means |
| T007 | 27 | 32 | 18 | new presentation | Why Perl Advocacy Is a Bad Idea |
| T008 | 28 | 33 | 16 | new presentation | NMS |
| T009 | 29 | 34 | 19 | new presentation | Idiotic Perl |
| T105 | 29 | 35 | 22 | new presentation | Idiotic Perl |
| T106 | 21 | 36 | 22 | new presentation | Idiomatic Perl |
| T010 | 21 | 37 | 20 | new presentation | Idiomatic Perl (extract) |
| T011 | 21 | 38 | 21 | new presentation | Idiomatic Perl (extract) |
| T013 | 30 | 39 | 23 | new presentation | Overload.pm |
| T014 | 30 | 40 | 25 | new presentation | Overloading in Perl |
| T015 | 26 | 41 | 25 | new presentation | Perl For The People |
| T016 | 22 | 42 | 26 | new presentation | Tieing and Overloading Objects in Perl |
| T018 | 31 | 43 | 24 | new presentation | Writing a Book Using The Template Toolkit |
| T019 | 32 | 44 | 27 | new presentation | Tieing |
| T020 | 33 | 45 | 28 | new presentation | Perl |
| T021 | 34 | 46 | 29 | new presentation | Introduction to the Template Toolkit |
| T107 | 21 | 23 | 12 | existing match | Idiomatic Perl |
| T108 | 22 | 24 | 12 | existing match | Tieing and Overloading Objects in Perl |
| T022 | 35 | 47 | 30 | new presentation | OO Perl |
| T023 | 36 | 48 | 31 | new presentation | Enterprise Perl |
| T024 | 37 | 49 | 32 | new presentation | The Perl Mongers Census |
| T025 | 38 | 50 | 33 | new presentation | Databases and Perl |
| T026 | 38 | 51 | 34 | new presentation | Databases and Perl |
| T027 | 39 | 52 | 35 | new presentation | What's Wrong With ORM? |
| T028 | 39 | 53 | 36 | new presentation | What's Wrong with ORM |
| T029 | 40 | 54 | 37 | new presentation | Advanced Databases for Beginners |
| T030 | 39 | 55 | 37 | new presentation | What's Wrong With ORM |
| T031 | 41 | 56 | 37 | new presentation | Programming Languages and Perl |
| T032 | 42 | 57 | 38 | new presentation | Teach-In Extract - OO Perl |
| T033 | 34 | 58 | 39 | new presentation | An Introduction to the Template Toolkit |
| T034 | 43 | 59 | 40 | new presentation | Beginners Perl Tutorial |
| T035 | 44 | 60 | 41 | new presentation | Perl Teach-In |
| T036 | 44 | 61 | 42 | new presentation | Perl Teach-In |
| T037 | 45 | 62 | 42 | new presentation | Proud to Use Perl |
| T038 | 46 | 63 | 42 | new presentation | Perl in RPM-Land |
| T039 | 47 | 64 | 42 | new presentation | Ye Compleat History of Ye Perle Mongers of Olde London Towne (Part 1) |
| T040 | 46 | 65 | 43 | new presentation | Perl in RPM Land |
| T041 | 47 | 66 | 44 | new presentation | The Complete History of the Perle Mongers of Olde London Towne (Parte One) |
| T042 | 48 | 67 | 44 | new presentation | Web Programming |
| T043 | 49 | 68 | 45 | new presentation | Why do so many companies re-invent well-known CPAN modules badly and end up writing far too much code? |
| T044 | 50 | 69 | 46 | new presentation | Introduction to Perl (day 1) |
| T045 | 50 | 70 | 46 | new presentation | Introduction to Perl (day 2) |
| T046 | 49 | 71 | 46 | new presentation | Why do so many companies re-invent well-known CPAN modules badly ... ? |
| T047 | 51 | 72 | 46 | new presentation | The Planetarium |
| T048 | 52 | 73 | 47 | new presentation | How I Maintain my CPAN Modules |
| T049 | 53 | 74 | 47 | new presentation | Teaching Perl - Experiences, Anecdotes and Vague Conclusions |
| T050 | 54 | 75 | 48 | new presentation | The "M" Word |
| T051 | 55 | 76 | 48 | new presentation | Skills in the Workplace |
| T052 | 8 | 77 | 48 | new presentation | The Professional Programmer |
| T053 | 56 | 78 | 49 | new presentation | Battersea Election Candidates at the General Election |
| T054 | 57 | 79 | 11 | new presentation | Introducing Modern Perl |
| T055 | 58 | 80 | 11 | new presentation | Things I Learned From Having Users |
| T056 | 20 | 22 | 11 | existing match | Perl Vogue |
| T057 | 59 | 81 | 11 | new presentation | The Perl Community |
| T058 | 60 | 82 | 50 | new presentation | Modern Perl |
| T059 | 61 | 83 | 51 | new presentation | Evolving Software with Moose |
| T060 | 62 | 84 | 52 | new presentation | Modern Web Programming in Perl - Part One |
| T061 | 62 | 85 | 52 | new presentation | Modern Web Programming in Perl - Part Two |
| T062 | 61 | 86 | 52 | new presentation | Evolving Software with Moose |
| T063 | 63 | 87 | 53 | new presentation | Watching the Press |
| T064 | 57 | 88 | 54 | new presentation | Introducing Modern Perl |
| T065 | 26 | 89 | 54 | new presentation | The Perl Community - A Modest Proposal |
| T066 | 64 | 90 | 54 | new presentation | Perl Training |
| T067 | 65 | 91 | 55 | new presentation | Modern Core Perl |
| T068 | 26 | 92 | 55 | new presentation | The Perl Community - A Modest Proposal |
| T069 | 66 | 93 | 56 | new presentation | Modern Perl for Non-Perl Programmers |
| T070 | 66 | 94 | 57 | new presentation | Modern Perl for Non-Perl Programmers |
| T071 | 67 | 95 | 58 | new presentation | Introduction to OO Perl with Moose |
| T072 | 68 | 96 | 58 | new presentation | Twenty Five Years of Perl in Twenty Five (ish) Minutes |
| T073 | 69 | 97 | 58 | new presentation | Matt's PSGI Archive |
| T074 | 69 | 98 | 59 | new presentation | Matt's PSGI Archive |
| T075 | 68 | 99 | 60 | new presentation | 25 Years of Perl in (about) 25 Minutes |
| T076 | 70 | 100 | 60 | new presentation | The Kingdom of the Blind |
| T077 | 69 | 101 | 60 | new presentation | Matt's PSGI Archive |
| T078 | 66 | 102 | 61 | new presentation | Modern Perl for Non-Perl Programmers |
| T079 | 70 | 103 | 61 | new presentation | The Kingdom of the Blind |
| T080 | 71 | 104 | 62 | new presentation | Github, Travis-CI and Perl |
| T081 | 72 | 105 | 63 | new presentation | Perl in the Internet of Things (Part One) |
| T082 | 72 | 106 | 63 | new presentation | Perl in the Internet of Things (Part Two) |
| T083 | 73 | 107 | 63 | new presentation | Return to the Kingdom of the Blind |
| T084 | 74 | 108 | 64 | new presentation | TwittElection |
| T085 | 75 | 109 | 65 | new presentation | Writing Books |
| T086 | 76 | 110 | 66 | new presentation | Database Development with Perl and DBIx::Class |
| T087 | 77 | 111 | 66 | new presentation | Modern PERL |
| T088 | 78 | 112 | 66 | new presentation | Conference Driven Publishing |
| T089 | 79 | 113 | 67 | new presentation | Modern Perl Web Development |
| T090 | 78 | 114 | 67 | new presentation | Conference Driven Publishing |
| T091 | 80 | 115 | 67 | new presentation | Improving Dev Assistant |
| T092 | 17 | 19 | 9 | existing match | Medium Perl |
| T093 | 16 | 18 | 9 | existing match | Error(s) Free Programming |
| T094 | 15 | 16 | 8 | existing match | Modern Perl Catch-Up |
| T095 | 16 | 17 | 8 | existing match | Error(s) Free Programming |
| T096 | 13 | 14 | 7 | existing match | Web Site Tune-Up - Improve Your Googlejuice |
| T097 | 14 | 15 | 7 | existing match | Adventures Beyond the Echo Chamber |
| T098 | 7 | 8 | 5 | existing match | Web Site Tune-Up - Improve Your Googlejuice |
| T099 | 8 | 9 | 5 | existing match | The Professional Programmer |
| T100 | 9 | 10 | 5 | existing match | Now We Are 20 |
| T101 | 10 | 11 | 5 | existing match | I'm a Republican, Honest! |
| T102 | 3 | 3 | 2 | existing match | Measuring the Quality of your Perl Code |
| T103 | 11 | 12 | 6 | existing match | Perl Diver |
| T104 | 12 | 13 | 6 | existing match | Perl School Catch-up |
