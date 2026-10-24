use strict;
use warnings;
use FindBin;
use Test::More;

system('python3', "$FindBin::Bin/backfill-import.py");
is($?, 0, 'backfill dry run, apply, repeat, precision and rollback checks pass');
done_testing;
