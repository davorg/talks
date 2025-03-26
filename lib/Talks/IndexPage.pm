use v5.36;
use feature 'class';
no warnings 'experimental::class';

class Talks::IndexPage;

field $title :param :reader;
field $url_path :param :reader;
field $description :param :reader;
field $og_type :param :reader = 'website';

method outfile {
  return "${url_path}index.html" =~ s|^/||r;
}

1;
