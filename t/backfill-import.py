import copy
import json
import pathlib
import sqlite3
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parent.parent


class BackfillImport(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = pathlib.Path(self.temp.name)
        self.db = self.path / 'archive.db'
        db = sqlite3.connect(self.db)
        db.executescript('''
            CREATE TABLE country (id INTEGER PRIMARY KEY, name TEXT UNIQUE);
            CREATE TABLE city (id INTEGER PRIMARY KEY, name TEXT UNIQUE, country_id INTEGER REFERENCES country(id));
            CREATE TABLE venue (id INTEGER PRIMARY KEY, name TEXT UNIQUE, city_id INTEGER REFERENCES city(id));
            CREATE TABLE year (id INTEGER PRIMARY KEY, year INTEGER UNIQUE);
            CREATE TABLE event_series (id INTEGER PRIMARY KEY, name TEXT UNIQUE);
            CREATE TABLE talk_type (id INTEGER PRIMARY KEY, type TEXT UNIQUE);
            CREATE TABLE talk (id INTEGER PRIMARY KEY, title TEXT, talk_type_id INTEGER REFERENCES talk_type(id));
            CREATE TABLE event (id INTEGER PRIMARY KEY, name TEXT, start_date TEXT, end_date TEXT,
                venue_id INTEGER REFERENCES venue(id), event_series_id INTEGER REFERENCES event_series(id),
                year_id INTEGER REFERENCES year(id), is_online INTEGER);
            CREATE TABLE presentation (id INTEGER PRIMARY KEY, talk_id INTEGER REFERENCES talk(id),
                event_id INTEGER REFERENCES event(id), datetime TEXT, title TEXT,
                slide_url TEXT, video_url TEXT, youtube_code TEXT, pdf_url TEXT);
            INSERT INTO talk_type VALUES (1, 'lightning'), (2, 'talk'), (3, 'tutorial'), (4, 'discussion');
            INSERT INTO event_series VALUES (1, 'YAPC/TPC/TPRC');
            INSERT INTO year VALUES (1, 2016);
            INSERT INTO event VALUES (1, 'YAPC Europe', '2016-08-23', '2016-08-26', NULL, 1, 1, 0);
            INSERT INTO talk VALUES (16, 'Error(s) Free Programming', 2), (21, 'Idiomatic Perl', 3);
            INSERT INTO presentation (id, talk_id, event_id, datetime) VALUES (18, 16, 1, '2016-08-26 15:05');
        ''')
        db.commit()
        db.close()
        catalogue = json.loads((ROOT / 'research/talk-backfill-2026-10-23/catalogue.json').read_text())
        ids = {'T058', 'T087', 'T010', 'T019', 'T093'}
        self.catalogue = {'records': [copy.deepcopy(r) for r in catalogue['records'] if r['id'] in ids],
                          'talk_groups': []}
        self.input = self.path / 'catalogue.json'
        self.report = self.path / 'report.json'
        self.input.write_text(json.dumps(self.catalogue))

    def run_import(self, *extra, success=True):
        result = subprocess.run(['python3', str(ROOT / 'bin/import-talk-backfill'),
            '--database', str(self.db), '--catalogue', str(self.input),
            '--report', str(self.report), *extra], capture_output=True, text=True)
        if success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            return json.loads(self.report.read_text())
        self.assertNotEqual(result.returncode, 0)
        return result

    def dump(self):
        with sqlite3.connect(self.db) as db:
            return '\n'.join(db.iterdump())

    def test_dry_run_and_repeat_apply(self):
        original = self.db.read_bytes()
        original_dump = self.dump()
        plan = self.run_import()
        self.assertEqual(self.db.read_bytes(), original, 'dry run leaves the archive byte-identical')
        self.assertEqual(len(plan['created_presentations']), 4)
        self.assertEqual(plan['existing_matches'], ['T093'])
        applied = self.run_import('--apply', '--backup', str(self.path / 'before.db'))
        with sqlite3.connect(self.path / 'before.db') as backup:
            self.assertEqual('\n'.join(backup.iterdump()), original_dump)
        self.assertEqual(plan['after'], applied['after'])
        before = self.dump()
        repeated = self.run_import('--apply', '--backup', str(self.path / 'repeat.db'))
        self.assertEqual(repeated['created_presentations'], [])
        self.assertEqual(len(repeated['already_imported']), 5)
        self.assertEqual(before, self.dump(), 'reapplying does not change any database data')

    def test_distinct_case_dates_extracts_and_provenance(self):
        self.run_import('--apply')
        with sqlite3.connect(self.db) as db:
            db.row_factory = sqlite3.Row
            lower = db.execute("SELECT * FROM talk WHERE title = 'Modern Perl'").fetchone()
            upper = db.execute("SELECT * FROM talk WHERE title = 'Modern PERL'").fetchone()
            self.assertNotEqual(lower['id'], upper['id'])
            self.assertIsNone(lower['url_slug'])
            self.assertEqual(upper['url_slug'], 'modern-perl-2015')
            uncertain = db.execute('''SELECT p.* FROM presentation p JOIN backfill_source b
                ON b.presentation_id = p.id WHERE b.source_id = 'T087' ''').fetchone()
            self.assertIsNone(uncertain['datetime'])
            self.assertIn('exact day not recorded', uncertain['date_label'])
            meeting = db.execute('''SELECT p.* FROM presentation p JOIN backfill_source b
                ON b.presentation_id = p.id WHERE b.source_id = 'T019' ''').fetchone()
            self.assertEqual(meeting['datetime'], '2003-11-17', 'meeting start is not imported as talk time')
            extract = db.execute('''SELECT p.* FROM presentation p JOIN backfill_source b
                ON b.presentation_id = p.id WHERE b.source_id = 'T010' ''').fetchone()
            self.assertEqual(extract['talk_id'], 21)
            self.assertEqual(extract['title'], 'Idiomatic Perl (extract)')
            self.assertEqual(db.execute('SELECT datetime FROM presentation WHERE id = 18').fetchone()[0],
                             '2016-08-25 15:05:00')
            for saved in db.execute('SELECT * FROM backfill_source'):
                record = next(r for r in self.catalogue['records'] if r['id'] == saved['source_id'])
                self.assertEqual(json.loads(saved['record_json']), record)
            self.assertEqual(db.execute('PRAGMA foreign_key_check').fetchall(), [])

    def test_unconfirmed_input_and_changed_reimports_roll_back(self):
        before = self.dump()
        self.catalogue['records'][0]['review'] = 'pending'
        self.input.write_text(json.dumps(self.catalogue))
        self.run_import('--apply', success=False)
        self.assertEqual(self.dump(), before)
        self.catalogue['records'][0]['review'] = 'confirmed'
        self.input.write_text(json.dumps(self.catalogue))
        self.run_import('--apply')
        before = self.dump()
        self.catalogue['records'][-1]['notes'].append('Changed after importing')
        self.input.write_text(json.dumps(self.catalogue))
        self.run_import('--apply', success=False)
        self.assertEqual(self.dump(), before, 'changed research cannot silently overwrite imported data')


if __name__ == '__main__':
    unittest.main()
